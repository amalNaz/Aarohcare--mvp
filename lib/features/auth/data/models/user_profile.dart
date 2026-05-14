class UserProfile {
  const UserProfile({
    required this.userName,
    required this.phoneNumber,
    required this.password,
    required this.place,
    required this.age,
    this.avatarBase64 = '',
  });

  final String userName;
  final String phoneNumber;
  final String password;
  final String place;
  final int age;
  final String avatarBase64;

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'phoneNumber': phoneNumber,
    'password': password,
    'place': place,
    'age': age,
    'avatarBase64': avatarBase64,
  };

  UserProfile copyWith({
    String? userName,
    String? phoneNumber,
    String? password,
    String? place,
    int? age,
    String? avatarBase64,
  }) {
    return UserProfile(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      place: place ?? this.place,
      age: age ?? this.age,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userName: (json['userName'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      place: (json['place'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      avatarBase64: (json['avatarBase64'] as String?) ?? '',
    );
  }
}
