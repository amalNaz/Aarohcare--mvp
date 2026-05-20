import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/animated_health_background.dart';
import '../../../splash/presentation/widgets/app_logo.dart';
import 'booking_record.dart';
import 'live_booking_store.dart';

class LiveTokenStatusPage extends StatefulWidget {
  const LiveTokenStatusPage({
    super.key,
    required this.currentRecord,
    required this.bookedRecords,
  });

  final BookingRecord currentRecord;
  final List<BookingRecord> bookedRecords;

  @override
  State<LiveTokenStatusPage> createState() => _LiveTokenStatusPageState();
}

class _LiveTokenStatusPageState extends State<LiveTokenStatusPage> {
  @override
  void initState() {
    super.initState();
    LiveBookingStore.instance.bookingsNotifier.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    LiveBookingStore.instance.bookingsNotifier.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final records =
        LiveBookingStore.instance.bookings.isNotEmpty
            ? LiveBookingStore.instance.bookings
            : widget.bookedRecords;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text('AarohCare'),
          ],
        ),
      ),
      body: AnimatedHealthBackground(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 24),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      loc.liveTokenStatus,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All booked tokens in sequence',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    _BookedRecordsSection(
                      records: records,
                      formatDate: _formatDate,
                      currentRecord: widget.currentRecord,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookedRecordsSection extends StatelessWidget {
  const _BookedRecordsSection({
    required this.records,
    required this.formatDate,
    required this.currentRecord,
  });

  final List<BookingRecord> records;
  final String Function(DateTime date) formatDate;
  final BookingRecord currentRecord;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E3A7BC8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.view_list_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All booked tokens',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (records.isEmpty)
            Text(
              'No bookings yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            )
          else
            Column(
              children: List.generate(records.length, (index) {
                final record = records[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == records.length - 1 ? 0 : 10,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 420 + (index * 90)),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 14),
                          child: child,
                        ),
                      );
                    },
                    child: _BookingRowCard(
                      serial: index + 1,
                      record: record,
                      formatDate: formatDate,
                      highlight:
                          record.tokenNumber == currentRecord.tokenNumber,
                    ),
                  ),
                );
              }),
            ),
          const SizedBox(height: 12),
          Text(
            '${loc.liveTokenStatus}: ${records.length} booking${records.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRowCard extends StatelessWidget {
  const _BookingRowCard({
    required this.serial,
    required this.record,
    required this.formatDate,
    required this.highlight,
  });

  final int serial;
  final BookingRecord record;
  final String Function(DateTime date) formatDate;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              highlight
                  ? [colorScheme.primary.withValues(alpha: 0.10), Colors.white]
                  : [Colors.white, const Color(0xFFF9FCFF)],
        ),
        border: Border.all(
          color:
              highlight
                  ? colorScheme.primary.withValues(alpha: 0.28)
                  : colorScheme.primary.withValues(alpha: 0.10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C3A7BC8),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$serial',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        record.tokenNumber,
                        style: TextStyle(
                          color:
                              highlight
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF0A3D62),
                          fontWeight: FontWeight.w900,
                          fontSize: highlight ? 21 : 18,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (highlight)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Latest',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.patientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(record.bookingDate),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
