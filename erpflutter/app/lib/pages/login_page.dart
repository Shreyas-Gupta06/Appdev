import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dashboard.dart';
import 'password_reset.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthService authService = AuthService();
  bool _isLoading = false;
  String _username = "";
  String _password = "";

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await authService.login(_username, _password);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("access")) {
      await storage.write(key: "access_token", value: response['access']);
      await storage.write(key: "refresh_token", value: response['refresh']);
      await storage.write(
        key: "user_data",
        value: jsonEncode(response['user']),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => _username = value,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              onChanged: (value) => _password = value,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordResetPage()),
                );
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
