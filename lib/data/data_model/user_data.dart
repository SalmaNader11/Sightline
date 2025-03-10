class UserData {
  final String username;
  final String email;
  final String phone;
  final String password;

  UserData({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  // Convert UserData to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'UserData(username: $username, email: $email, phone: $phone, password: $password)';
  }
}