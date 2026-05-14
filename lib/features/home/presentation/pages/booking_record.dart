enum BookingStatus { booked, arrived, completed, cancelled }

class BookingRecord {
  const BookingRecord({
    this.id = '',
    required this.tokenNumber,
    this.opNumber = '',
    required this.patientName,
    this.phoneNumber = '',
    required this.age,
    required this.bookingDate,
    required this.clinic,
    required this.doctor,
    this.status = BookingStatus.booked,
    this.createdAt,
    this.arrivedAt,
  });

  final String id;
  final String tokenNumber;
  final String opNumber;
  final String patientName;
  final String phoneNumber;
  final int age;
  final DateTime bookingDate;
  final String clinic;
  final String doctor;
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? arrivedAt;

  BookingRecord copyWith({
    String? id,
    String? tokenNumber,
    String? opNumber,
    String? patientName,
    String? phoneNumber,
    int? age,
    DateTime? bookingDate,
    String? clinic,
    String? doctor,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? arrivedAt,
    bool clearArrivedAt = false,
  }) {
    return BookingRecord(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      opNumber: opNumber ?? this.opNumber,
      patientName: patientName ?? this.patientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      bookingDate: bookingDate ?? this.bookingDate,
      clinic: clinic ?? this.clinic,
      doctor: doctor ?? this.doctor,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      arrivedAt: clearArrivedAt ? null : arrivedAt ?? this.arrivedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenNumber': tokenNumber,
        'opNumber': opNumber,
        'patientName': patientName,
      'phoneNumber': phoneNumber,
        'age': age,
        'bookingDate': bookingDate.toIso8601String(),
        'clinic': clinic,
        'doctor': doctor,
        'status': status.name,
        'createdAt': createdAt?.toIso8601String(),
        'arrivedAt': arrivedAt?.toIso8601String(),
  };

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    return BookingRecord(
      id: (json['id'] as String?) ?? '',
      tokenNumber: (json['tokenNumber'] as String?) ?? '',
      opNumber: (json['opNumber'] as String?) ?? '',
      patientName: (json['patientName'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      bookingDate:
          DateTime.tryParse((json['bookingDate'] as String?) ?? '') ??
          DateTime.now(),
      clinic: (json['clinic'] as String?) ?? '',
      doctor: (json['doctor'] as String?) ?? '',
      status: BookingStatus.values.firstWhere(
        (value) => value.name == (json['status'] as String? ?? 'booked'),
        orElse: () => BookingStatus.booked,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      arrivedAt: DateTime.tryParse(json['arrivedAt'] as String? ?? ''),
    );
  }
}
