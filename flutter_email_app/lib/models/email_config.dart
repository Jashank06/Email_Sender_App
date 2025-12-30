class EmailConfig {
  final String provider; // 'gmail' or 'outlook'
  final String email;
  final String password;
  
  EmailConfig({
    required this.provider,
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'email': email,
      'password': password,
    };
  }
  
  factory EmailConfig.fromJson(Map<String, dynamic> json) {
    return EmailConfig(
      provider: json['provider'],
      email: json['email'],
      password: json['password'],
    );
  }
}
