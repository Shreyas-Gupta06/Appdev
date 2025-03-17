import 'dart:convert';

class User {
  String? id; //all nullable intially
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? userType;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.userType,
    this.createdAt,
    this.updatedAt,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['user_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Convert User object to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "user_type": userType,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }

  // Convert to JSON string for storage
  String toJsonString() => jsonEncode(toJson());

  // Create User object from stored JSON string
  static User fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }
}
