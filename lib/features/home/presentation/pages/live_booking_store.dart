import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'booking_record.dart';

class LiveBookingStore {
  LiveBookingStore._();

  static final LiveBookingStore instance = LiveBookingStore._();

  static const String _bookingsKey = 'booking_records';
  static const String _slotsKey = 'slot_entries';
  static const String _currentOpKey = 'current_op_number';

  bool _initialized = false;
  bool _isHydrating = false;
  bool _isSyncingCurrentOp = false;

  Timer? _currentOpSyncTimer;

  final ValueNotifier<List<BookingRecord>> bookingsNotifier =
      ValueNotifier<List<BookingRecord>>(<BookingRecord>[]);

  static const int defaultSlotCount = 12;

  final ValueNotifier<List<SlotEntry?>> slotsNotifier =
      ValueNotifier<List<SlotEntry?>>(
        List<SlotEntry?>.filled(defaultSlotCount, null, growable: true),
      );

  final ValueNotifier<int> currentTokenNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> currentOpNumberNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> activePatientNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<DateTime?> lastUpdatedNotifier = ValueNotifier<DateTime?>(
    null,
  );

  int _nextOpNumber = 1;
  int _nextToken = 1;
  final Set<String> _knownBookingIds = <String>{};

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _hydrateBookingsFromDisk();
    await _hydrateSlotsFromDisk();
    await _hydrateCurrentOpFromDisk();
    bookingsNotifier.addListener(_persistBookingsListener);
    slotsNotifier.addListener(_persistSlotsListener);
    currentOpNumberNotifier.addListener(_persistCurrentOpListener);

    // On Web, SharedPreferences maps to localStorage which is shared across tabs.
    // Polling allows admin changes in one tab to reflect on a user tab.
    if (kIsWeb) {
      _currentOpSyncTimer ??= Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => unawaited(_refreshCurrentOpFromDisk()),
      );
    }
  }

  Future<void> _refreshCurrentOpFromDisk() async {
    if (_isHydrating || _isSyncingCurrentOp) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_currentOpKey);
      if (saved == null) return;
      final normalized = saved < 0 ? 0 : saved;
      if (normalized == currentOpNumberNotifier.value) return;

      _isSyncingCurrentOp = true;
      currentOpNumberNotifier.value = normalized;
      lastUpdatedNotifier.value = DateTime.now();
    } catch (_) {
      // Best-effort; ignore refresh failures.
    } finally {
      _isSyncingCurrentOp = false;
    }
  }

  Future<void> _hydrateBookingsFromDisk() async {
    _isHydrating = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_bookingsKey) ?? <String>[];
      if (saved.isEmpty) return;

      final records = <BookingRecord>[];
      for (final entry in saved) {
        try {
          if (entry.isEmpty) continue;
          final decoded = BookingRecord.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          );
          records.add(decoded);
        } catch (_) {
          // Ignore malformed entries.
        }
      }

      if (records.isEmpty) return;

      // Restore records directly; do not regenerate OP/token.
      bookingsNotifier.value = [...records]..sort(_bookingSort);
      _knownBookingIds
        ..clear()
        ..addAll(
          records.map((record) => record.id).where((id) => id.isNotEmpty),
        );

      // Keep counters consistent with persisted data.
      _nextToken = _computeNextToken(records);
      _nextOpNumber = _computeNextOp(records);
      _refreshMeta();
    } finally {
      _isHydrating = false;
    }
  }

  Future<void> _hydrateSlotsFromDisk() async {
    _isHydrating = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_slotsKey);
      if (saved == null) return;

      final slots = <SlotEntry?>[];
      for (final entry in saved) {
        if (entry.isEmpty) {
          slots.add(null);
          continue;
        }
        try {
          final decoded = jsonDecode(entry) as Map<String, dynamic>;
          slots.add(SlotEntry.fromJson(decoded));
        } catch (_) {
          slots.add(null);
        }
      }

      if (slots.isEmpty) return;
      slotsNotifier.value = List<SlotEntry?>.unmodifiable(slots);
    } finally {
      _isHydrating = false;
    }
  }

  int _computeNextToken(List<BookingRecord> records) {
    var maxToken = 0;
    for (final record in records) {
      final value =
          int.tryParse(record.tokenNumber.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      if (value > maxToken) maxToken = value;
    }
    return maxToken + 1;
  }

  int _computeNextOp(List<BookingRecord> records) {
    var maxOp = 0;
    for (final record in records) {
      final value =
          int.tryParse(record.opNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (value > maxOp) maxOp = value;
    }
    return maxOp + 1;
  }

  Future<void> _hydrateCurrentOpFromDisk() async {
    _isHydrating = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_currentOpKey) ?? 0;
      currentOpNumberNotifier.value = saved < 0 ? 0 : saved;
    } finally {
      _isHydrating = false;
    }
  }

  int _tokenValue(BookingRecord record) {
    return int.tryParse(record.tokenNumber.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  void _persistBookingsListener() {
    unawaited(_persistBookings());
  }

  void _persistSlotsListener() {
    unawaited(_persistSlots());
  }

  void _persistCurrentOpListener() {
    unawaited(_persistCurrentOp());
  }

  Future<void> _persistBookings() async {
    if (_isHydrating) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = bookingsNotifier.value
          .map((record) => jsonEncode(record.toJson()))
          .toList(growable: false);
      await prefs.setStringList(_bookingsKey, encoded);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  Future<void> _persistSlots() async {
    if (_isHydrating) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = slotsNotifier.value
          .map((entry) => entry == null ? '' : jsonEncode(entry.toJson()))
          .toList(growable: false);
      await prefs.setStringList(_slotsKey, encoded);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  int? _slotIndexForOp(String opNumber) {
    final digits =
        RegExp(r'\d+').allMatches(opNumber).map((m) => m.group(0)!).join();
    final op = int.tryParse(digits.isEmpty ? opNumber.trim() : digits);
    if (op == null || op <= 0) return null;
    return op - 1;
  }

  String _normalizeOpNumber(String raw) {
    return RegExp(r'\d+').allMatches(raw).map((m) => m.group(0)!).join();
  }

  String _formatOpNumber(String raw) {
    final digits = _normalizeOpNumber(raw);
    if (digits.isEmpty) return raw;
    return 'OP-$digits';
  }

  bool _isOpOccupied(String opNumber) {
    final normalizedOp = _normalizeOpNumber(opNumber);
    if (normalizedOp.isEmpty) return false;

    final opIsTakenByBooking = bookingsNotifier.value.any(
      (booking) => _normalizeOpNumber(booking.opNumber) == normalizedOp,
    );

    final opIsReservedInSlot = slotsNotifier.value.any(
      (entry) => entry != null &&
          _normalizeOpNumber(entry.opNumber) == normalizedOp,
    );

    return opIsTakenByBooking || opIsReservedInSlot;
  }

  int _findNextAvailableOpNumber() {
    var candidate = 1;
    while (_isOpOccupied('OP-$candidate')) {
      candidate += 1;
    }
    return candidate;
  }

  void _upsertBookingFromSlot(SlotEntry slotEntry) {
    final opLabel = _formatOpNumber(slotEntry.opNumber);
    final numericOp = int.tryParse(_normalizeOpNumber(opLabel));
    final existingIndex = bookingsNotifier.value.indexWhere(
      (booking) => _normalizeOpNumber(booking.opNumber) ==
          _normalizeOpNumber(opLabel),
    );

    if (existingIndex != -1) {
      final updated = bookingsNotifier.value[existingIndex].copyWith(
        patientName: slotEntry.patientName,
        phoneNumber: slotEntry.phoneNumber,
        age: slotEntry.age,
        opNumber: opLabel,
      );
      final list = [...bookingsNotifier.value];
      list[existingIndex] = updated;
      bookingsNotifier.value = list;
      _sortAndRefresh();
      return;
    }

    final booking = BookingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tokenNumber: 'T-${_nextToken++}',
      opNumber: opLabel,
      patientName: slotEntry.patientName,
      phoneNumber: slotEntry.phoneNumber,
      age: slotEntry.age,
      bookingDate: DateTime.now(),
      clinic: 'Alshifa Medicals',
      doctor: 'Admin Reserved',
      status: BookingStatus.booked,
      createdAt: DateTime.now(),
    );

    _nextOpNumber = max(_nextOpNumber, (numericOp ?? 0) + 1);
    _knownBookingIds.add(booking.id);
    bookingsNotifier.value = [...bookingsNotifier.value, booking];
    _fillSlotForBooking(booking);
    _sortAndRefresh();
  }

  void removeBookingByOpNumber(String opNumber) {
    final normalized = _normalizeOpNumber(opNumber);
    if (normalized.isEmpty) return;

    final list = bookingsNotifier.value
        .where(
          (booking) => _normalizeOpNumber(booking.opNumber) != normalized,
        )
        .toList();

    if (list.length == bookingsNotifier.value.length) return;

    bookingsNotifier.value = list;
    _refreshMeta();
  }

  void _fillSlotForBooking(BookingRecord booking) {
    final index = _slotIndexForOp(booking.opNumber);
    if (index == null) return;
    ensureSlotCount(index + 1);
    final current =
        index < slotsNotifier.value.length ? slotsNotifier.value[index] : null;
    if (current != null) return;

    final normalizedOp =
        RegExp(
          r'\d+',
        ).allMatches(booking.opNumber).map((m) => m.group(0)!).join();

    setSlot(
      index,
      SlotEntry(
        patientName: booking.patientName,
        phoneNumber: booking.phoneNumber,
        age: booking.age,
        opNumber: normalizedOp.isEmpty ? booking.opNumber : normalizedOp,
      ),
    );
  }

  List<BookingRecord> get bookings =>
      List<BookingRecord>.unmodifiable(bookingsNotifier.value);

  List<SlotEntry?> get slots =>
      List<SlotEntry?>.unmodifiable(slotsNotifier.value);

  void ensureSlotCount(int minCount) {
    if (minCount <= 0) return;
    if (slotsNotifier.value.length >= minCount) return;
    final list = [...slotsNotifier.value];
    list.addAll(List<SlotEntry?>.filled(minCount - list.length, null));
    slotsNotifier.value = list;
  }

  void setSlot(int index, SlotEntry? entry) {
    if (index < 0) return;
    // Avoid allocating huge lists when user scrolls far and taps an empty slot.
    // Only grow the list if we're writing a real entry.
    if (index >= slotsNotifier.value.length && entry == null) return;
    ensureSlotCount(index + 1);
    final list = [...slotsNotifier.value];
    list[index] = entry;
    slotsNotifier.value = list;
  }

  void clearSlot(int index) {
    if (index < 0 || index >= slotsNotifier.value.length) return;
    final opNumber = _formatOpNumber('${index + 1}');
    removeBookingByOpNumber(opNumber);
    setSlot(index, null);
  }

  void reserveSlot(int index, SlotEntry entry) {
    if (index < 0) return;
    ensureSlotCount(index + 1);
    setSlot(index, entry);
    _upsertBookingFromSlot(entry);
  }

  void seedBookings(List<BookingRecord> records) {
    if (records.isEmpty) return;
    var changed = false;
    for (final record in records) {
      final id = record.id.isEmpty ? record.tokenNumber : record.id;
      if (_knownBookingIds.contains(id)) continue;
      _knownBookingIds.add(id);
      final normalized = record.copyWith(
        id: id,
        opNumber:
            record.opNumber.isEmpty ? 'OP-$_nextOpNumber' : record.opNumber,
        status: record.status,
      );
      _nextOpNumber += 1;
      _nextToken = _nextToken < _nextOpNumber ? _nextOpNumber : _nextToken;
      bookingsNotifier.value = <BookingRecord>[
        ...bookingsNotifier.value,
        normalized,
      ];
      changed = true;
    }
    if (changed) {
      _sortAndRefresh();
    }
  }

  BookingRecord addBooking({
    required String patientName,
    required String phoneNumber,
    required int age,
    required DateTime bookingDate,
    required String clinic,
    required String doctor,
  }) {
    final nextOpId = _findNextAvailableOpNumber().toString();
    final opNumber = _formatOpNumber(nextOpId);
    final booking = BookingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tokenNumber: 'T-${_nextToken++}',
      opNumber: opNumber,
      patientName: patientName,
      phoneNumber: phoneNumber,
      age: age,
      bookingDate: bookingDate,
      clinic: clinic,
      doctor: doctor,
      status: BookingStatus.booked,
      createdAt: DateTime.now(),
    );
    _nextOpNumber = max(_nextOpNumber, int.tryParse(nextOpId)! + 1);
    _knownBookingIds.add(booking.id);
    bookingsNotifier.value = <BookingRecord>[
      ...bookingsNotifier.value,
      booking,
    ];
    _fillSlotForBooking(booking);
    _sortAndRefresh();
    return booking;
  }

  void updateBooking(BookingRecord updated) {
    final index = bookingsNotifier.value.indexWhere(
      (booking) => booking.id == updated.id,
    );
    if (index == -1) return;
    final list = [...bookingsNotifier.value];
    list[index] = updated;
    bookingsNotifier.value = list;
    _fillSlotForBooking(updated);
    _refreshMeta();
  }

  void markCurrentPatientArrived() {
    final current =
        bookingsNotifier.value
            .where((booking) => booking.status == BookingStatus.booked)
            .toList()
          ..sort(_bookingSort);
    if (current.isEmpty) return;
    final updated = current.first.copyWith(
      status: BookingStatus.arrived,
      arrivedAt: DateTime.now(),
    );
    updateBooking(updated);
  }

  void advanceToken() {
    final currentToken = currentTokenNotifier.value;
    final next =
        bookingsNotifier.value
            .where((booking) => _tokenValue(booking) > currentToken)
            .toList()
          ..sort(_bookingSort);
    if (next.isEmpty) {
      currentTokenNotifier.value = 0;
      activePatientNotifier.value = null;
      lastUpdatedNotifier.value = DateTime.now();
      return;
    }

    setCurrentToken(_tokenValue(next.first));
  }

  Future<void> _persistCurrentOp() async {
    if (_isHydrating || _isSyncingCurrentOp) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentOpKey, currentOpNumberNotifier.value);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  void backwardToken() {
    final currentToken = currentTokenNotifier.value;
    if (currentToken <= 0) {
      setCurrentToken(0);
      return;
    }
    setCurrentToken(currentToken - 1);
  }

  void advanceOpNumber() {
    setCurrentOpNumber(currentOpNumberNotifier.value + 1);
  }

  void backwardOpNumber() {
    setCurrentOpNumber(currentOpNumberNotifier.value - 1);
  }

  void setCurrentOpNumber(int opNumber) {
    if (opNumber < 0) {
      currentOpNumberNotifier.value = 0;
      return;
    }
    currentOpNumberNotifier.value = opNumber;
    lastUpdatedNotifier.value = DateTime.now();
  }

  void setCurrentToken(int token) {
    if (token < 0) return;

    final now = DateTime.now();
    final list =
        bookingsNotifier.value.map((booking) {
            final value = _tokenValue(booking);
            if (token == 0) {
              return booking.copyWith(
                status: BookingStatus.booked,
                clearArrivedAt: true,
              );
            }
            if (value <= token && value > 0) {
              return booking.copyWith(
                status: BookingStatus.arrived,
                arrivedAt: booking.arrivedAt ?? now,
              );
            }
            return booking.copyWith(
              status: BookingStatus.booked,
              clearArrivedAt: true,
            );
          }).toList()
          ..sort(_bookingSort);

    final active = list.where((booking) => _tokenValue(booking) == token);
    bookingsNotifier.value = list;
    currentTokenNotifier.value = token;
    activePatientNotifier.value =
        active.isEmpty ? null : active.first.patientName;
    lastUpdatedNotifier.value = now;
  }

  void removeBooking(String bookingId) {
    final list =
        bookingsNotifier.value
            .where((booking) => booking.id != bookingId)
            .toList();
    bookingsNotifier.value = list;
    _refreshMeta();
  }

  void setBookingDetails({
    required String bookingId,
    required String patientName,
    required int age,
    String? opNumber,
  }) {
    final index = bookingsNotifier.value.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index == -1) return;
    final current = bookingsNotifier.value[index];
    final list = [...bookingsNotifier.value];
    list[index] = current.copyWith(
      patientName: patientName,
      age: age,
      opNumber: opNumber ?? current.opNumber,
    );
    bookingsNotifier.value = list;
    _refreshMeta();
  }

  void _sortAndRefresh() {
    bookingsNotifier.value = [...bookingsNotifier.value]..sort(_bookingSort);
    _refreshMeta();
  }

  int _bookingSort(BookingRecord a, BookingRecord b) {
    final aToken =
        int.tryParse(a.tokenNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final bToken =
        int.tryParse(b.tokenNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return aToken.compareTo(bToken);
  }

  void _refreshMeta() {
    final current =
        bookingsNotifier.value
            .where((booking) => booking.status == BookingStatus.arrived)
            .toList()
          ..sort(_bookingSort);
    currentTokenNotifier.value =
        current.isEmpty
            ? 0
            : (int.tryParse(
                  current.last.tokenNumber.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0);
    activePatientNotifier.value =
        current.isEmpty ? null : current.last.patientName;
    lastUpdatedNotifier.value = DateTime.now();
  }
}

class SlotEntry {
  const SlotEntry({
    required this.patientName,
    required this.phoneNumber,
    required this.age,
    required this.opNumber,
  });

  final String patientName;
  final String phoneNumber;
  final int age;
  final String opNumber;

  Map<String, dynamic> toJson() => {
    'patientName': patientName,
    'phoneNumber': phoneNumber,
    'age': age,
    'opNumber': opNumber,
  };

  factory SlotEntry.fromJson(Map<String, dynamic> json) {
    return SlotEntry(
      patientName: (json['patientName'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      opNumber: (json['opNumber'] as String?) ?? '',
    );
  }
}
