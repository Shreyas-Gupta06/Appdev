import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pages/home.dart';
import 'pages/dashboard.dart';
import 'pages/email_verification_page.dart';
import 'pages/phone_verification_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();

  Future<Widget> _checkAuthStatus() async {
    print("🔍 Fetching user data...");
    await authService.getUserData();

    if (AuthService.currentUser == null) {
      print("🚪 No user found. Redirecting to HomePage.");
      return HomePage();
    }

    print("👤 User found: ${AuthService.currentUser!.email}");

    if (!AuthService.currentUser!.emailVerified) {
      print("📧 Email not verified. Redirecting to EmailVerificationPage.");
      return EmailVerificationPage();
    }

    print("✅ Email verified.");

    if (!AuthService.currentUser!.phoneVerified) {
      print("📞 Phone not verified. Redirecting to PhoneVerificationPage.");
      return PhoneVerificationPage();
    }

    print("✅ Phone verified. Redirecting to Dashboard.");
    return DashboardPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          return MaterialApp(home: snapshot.data ?? HomePage());
        }
      },
    );
  }
}
