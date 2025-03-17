import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = "http://srijansahay05.in/api/users/";
  final FlutterSecureStorage storage = FlutterSecureStorage();
  static User? currentUser; // Cached user object

  // Register function (passwords passed separately)
  Future<Map<String, dynamic>> register(
    User user,
    String password,
    String password2,
  ) async {
    try {
      String url = "${baseUrl}register/";
      Map<String, dynamic> body = user.toJson();
      body['password'] = password;
      body['password2'] = password2;

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: "access_token", value: data['access']);
        await storage.write(key: "refresh_token", value: data['refresh']);

        currentUser = User.fromJson(data['user']); // Store as User model
        await storage.write(key: "user_data", value: jsonEncode(data['user']));

        return data['user'];
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      String url = "${baseUrl}login/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "access_token", value: data['access']);
        await storage.write(key: "refresh_token", value: data['refresh']);

        currentUser = User.fromJson(data['user']); // Store as User model
        await storage.write(key: "user_data", value: jsonEncode(data['user']));

        return data['user'];
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      String url = "${baseUrl}verify-email/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(String email, String otp) async {
    try {
      String url = "${baseUrl}verify-email/";

      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

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

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      String url = "${baseUrl}reset-password/";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      String url = "${baseUrl}reset-password/";

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
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: "access_token");
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await storage.read(key: "refresh_token");
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse("${baseUrl}token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "access_token", value: data['access']);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  Future<User?> getUserData() async {
    try {
      if (currentUser != null) {
        return currentUser; // Use cached user
      }

      // Check storage first
      final storedData = await storage.read(key: "user_data");
      if (storedData != null) {
        currentUser = User.fromJson(jsonDecode(storedData));
        return currentUser;
      }

      // If not in storage, fetch from API
      final accessToken = await storage.read(key: "access_token");
      if (accessToken == null) return null;

      final response = await http.get(
        Uri.parse("${baseUrl}dashboard/"),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        currentUser = User.fromJson(data);
        await storage.write(key: "user_data", value: jsonEncode(data));
        return currentUser;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
