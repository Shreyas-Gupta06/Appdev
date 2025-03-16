import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl = "http://localhost:8000/api/users";

  // Register function (passwords passed separately)
  Future<Map<String, dynamic>> register(
    User user,
    String password,
    String password2,
  ) async {
    try {
      String url = "$baseUrl/register/";

      // Convert User object to JSON, then add passwords dynamically
      Map<String, dynamic> body = user.toJson();
      body['password'] = password;
      body['password2'] = password2;

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      String url = "$baseUrl/login/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success: returns user data + tokens
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Send OTP to email (POST request)
  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      String url = "$baseUrl/verify-email/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Verify OTP (PUT request)
  Future<Map<String, dynamic>> verifyEmailOTP(String email, String otp) async {
    try {
      String url = "$baseUrl/verify-email/";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Send OTP to phone (POST request)
  Future<Map<String, dynamic>> sendPhoneOTP(String phone) async {
    try {
      String url = "$baseUrl/verify-phone/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Verify OTP for phone (PUT request)
  Future<Map<String, dynamic>> verifyPhoneOTP(String phone, String otp) async {
    try {
      String url = "$baseUrl/verify-phone/";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Request password reset (POST request)
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      String url = "$baseUrl/reset-password/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  // Reset password with OTP (PUT request)
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      String url = "$baseUrl/reset-password/";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Success response
      } else {
        return {"error": jsonDecode(response.body)}; // API error response
      }
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }
}
