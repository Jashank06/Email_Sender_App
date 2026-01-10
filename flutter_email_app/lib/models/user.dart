class User {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String savedEmail;
  final String savedPassword;
  final String savedProvider;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.savedEmail = '',
    this.savedPassword = '',
    this.savedProvider = 'gmail',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      savedEmail: json['savedEmail'] ?? '',
      savedPassword: json['savedPassword'] ?? '',
      savedProvider: json['savedProvider'] ?? 'gmail',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'savedEmail': savedEmail,
      'savedPassword': savedPassword,
      'savedProvider': savedProvider,
    };
  }

  User copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? savedEmail,
    String? savedPassword,
    String? savedProvider,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      savedEmail: savedEmail ?? this.savedEmail,
      savedPassword: savedPassword ?? this.savedPassword,
      savedProvider: savedProvider ?? this.savedProvider,
    );
  }
}
