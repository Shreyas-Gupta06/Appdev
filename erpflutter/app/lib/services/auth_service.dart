import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AuthService {
  final String baseUrl = "http://148.66.152.80/api/users/";
  final FlutterSecureStorage storage = FlutterSecureStorage();
  static User? currentUser; // Cached user object

  // Register function (passwords passed separately)
  Future<Map<String, dynamic>> register(
    User user,
    String password,
    String password2,
  ) async {
    String url = "${baseUrl}register/";
    Map<String, dynamic> body = user.toJson();
    body['password'] = password;
    body['password2'] = password2;

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    print("🔥 DEBUG: Full API Response -> $data");

    // First, check if the response contains errors
    if (response.statusCode != 201) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage = "";

      if (errorResponse.containsKey("error")) {
        errorMessage = errorResponse["error"].toString();
      } else {
        errorMessage = errorResponse.values.map((e) => e.toString()).join(", ");
      }

      return {"error": errorMessage};
    }

    // If no errors, proceed with user creation
    await storage.write(key: "access_token", value: data['access']);
    await storage.write(key: "refresh_token", value: data['refresh']);

    // Ensure `id` is stored as a String
    String userId = data["user"]["id"].toString();

    Map<String, dynamic> currentUser = {
      "id": userId,
      "username": user.username,
      "first_name": user.firstName,
      "last_name": user.lastName,
      "email": user.email,
      "phone": user.phone,
      "user_type": user.userType,
      "created_at": data["user"]["created_at"],
      "updated_at": data["user"]["updated_at"],
      "email_verified": false, // ✅ Added email verification status
      "phone_verified": false,
    };

    await storage.write(key: "user_data", value: jsonEncode(currentUser));
    print("🛠 Stored user data: $currentUser");

    return currentUser;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    String url = "${baseUrl}login/";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(response.body);
    print("🔥 DEBUG: Full API Response -> $data");

    // First, check if the response contains errors
    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage = "";

      if (errorResponse.containsKey("error")) {
        errorMessage = errorResponse["error"].toString();
      } else {
        errorMessage = errorResponse.values.map((e) => e.toString()).join(", ");
      }

      return {"error": errorMessage};
    }

    // If no errors, proceed with user authentication
    await storage.write(key: "access_token", value: data['access']);
    await storage.write(key: "refresh_token", value: data['refresh']);

    // Ensure `id` and `phone` are stored as Strings
    String userId = data["user"]["id"].toString();
    String phone = data["user"]["phone"]?.toString() ?? "";

    Map<String, dynamic> currentUserData = {
      "id": userId,
      "username": data["user"]["username"] ?? "",
      "first_name": data["user"]["first_name"] ?? "",
      "last_name": data["user"]["last_name"] ?? "",
      "email": data["user"]["email"] ?? "",
      "phone": phone,
      "user_type": data["user"]["user_type"] ?? "applicant",
      "created_at": data["user"]["created_at"],
      "updated_at": data["user"]["updated_at"],
      "email_verified": true, // ✅ Added email verification status
      "phone_verified": true,
    };

    await storage.write(key: "user_data", value: jsonEncode(currentUserData));
    print("🛠 Stored user data: $currentUserData");

    return currentUserData;
  }

  Future<Map<String, dynamic>> sendEmailOTP(String email) async {
    try {
      String url = "${baseUrl}verify-email/";
      print("📨 Sending OTP Request to: $url");
      print("📧 Email: $email");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("🔍 Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      print("❌ Error Sending OTP: $e");
      return {"error": "Something went wrong: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(String email, String otp) async {
    try {
      String url = "${baseUrl}verify-email/";
      print("✅ Verifying OTP at: $url");
      print("📧 Email: $email, 🔢 OTP: $otp");

      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      print("🔍 Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"error": jsonDecode(response.body)};
    } catch (e) {
      print("❌ Error Verifying OTP: $e");
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
    await DefaultCacheManager().emptyCache();
  }

  Future<User?> getUserData() async {
    try {
      // print("🔍 Checking if user is cached...");
      // if (currentUser != null) {
      //   print("✅ Returning cached user.");
      //   return currentUser;
      // }

      // print("🔍 Checking stored user data...");
      final storedData = await storage.read(key: "user_data");
      if (storedData != null) {
        print("✅ Found user in storage.");
        print("📂 Stored user data: $storedData");

        // Debug: Print parsed JSON before converting to User object
        final parsedData = jsonDecode(storedData);
        print("🛠 Parsed stored data: $parsedData");

        currentUser = User.fromJson(parsedData);
        return currentUser;
      }

      // print("🔍 Checking access token...");
      // final accessToken = await storage.read(key: "access_token");
      // if (accessToken == null) {
      //   print("❌ No access token found!");
      //   return null;
      // }

      // print("📡 Fetching user data from API...");
      // final response = await http.get(
      //   Uri.parse("${baseUrl}dashboard/"),
      //   headers: {"Authorization": "Bearer $accessToken"},
      // );

      // print("📡 API Response: ${response.body}");

      // if (response.statusCode == 200) {
      //   final userData = jsonDecode(response.body)['user'];

      //   // Ensure `id`, `phone`, `created_at`, and `updated_at` are Strings
      //   String userId = userData["id"]?.toString() ?? "";
      //   String phone = userData['phone']?.toString() ?? "";
      //   String createdAt = userData["created_at"]?.toString() ?? "";
      //   String updatedAt = userData["updated_at"]?.toString() ?? "";

      //   // Store user data safely
      //   Map<String, dynamic> formattedUserData = {
      //     "id": userId, // ✅ Ensure id is stored as a String
      //     "username": userData["username"] ?? "",
      //     "first_name": userData["first_name"] ?? "",
      //     "last_name": userData["last_name"] ?? "",
      //     "email": userData["email"] ?? "",
      //     "phone": phone, // ✅ Ensure phone is stored as a String
      //     "user_type": userData["user_type"] ?? "applicant",
      //     "created_at": createdAt, // ✅ Ensure created_at is stored as a String
      //     "updated_at": updatedAt, // ✅ Ensure updated_at is stored as a String
      //   };

      //   print("🛠 Formatted User Data: $formattedUserData");

      //   await storage.write(
      //     key: "user_data",
      //     value: jsonEncode(formattedUserData),
      //   );

      //   currentUser = User.fromJson(formattedUserData);
      //   print("✅ User data successfully fetched and stored.");
      //   return currentUser;
      // }

      // print("❌ API call failed. Status Code: ${response.statusCode}");
      // return null;
    } catch (e) {
      print("❌ Error fetching user data: $e");
      return null;
    }
  }
}
