class User {
  String? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? userType;
  bool signedIn;
  bool emailVerified; // ✅ New field
  bool phoneVerified; // New attribute

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.userType,
    this.signedIn = false,
    this.emailVerified = false, // Default: false
    this.phoneVerified = false, // Default: false
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'],
      // signedIn: json['signedIn'] ?? false, // Ensure it defaults to false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'user_type': userType,
      // 'signedIn': signedIn, // Include it in JSON
    };
  }
}
