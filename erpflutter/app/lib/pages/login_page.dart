import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dashboard.dart';
import 'password_reset.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _username = "";
  String _password = "";
  String _errorMessage = "";

  final Color primaryColor = Colors.deepPurple; // Purple theme color

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = ""; // Clear error message before login attempt
    });

    final response = await authService.login(_username, _password);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("access")) {
      String accessToken = response['access'];
      String refreshToken = response['refresh'];
      Map<String, dynamic> userData = response['user'];

      // Save tokens securely
      await storage.write(key: "access_token", value: accessToken);
      await storage.write(key: "refresh_token", value: refreshToken);
      await storage.write(key: "user_data", value: jsonEncode(userData));

      // ✅ Set current user
      AuthService.currentUser = User(
        id: userData['id'] ?? 0,
        username: userData['username'] ?? "",
        firstName: userData['first_name'] ?? "",
        lastName: userData['last_name'] ?? "",
        email: userData['email'] ?? "",
        phone: userData['phone'] ?? "",
        userType: userData['user_type'] ?? "applicant",
        signedIn: true,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid username or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: primaryColor)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField("Username", false, (value) => _username = value),
              SizedBox(height: 15),
              _buildTextField("Password", true, (value) => _password = value),
              SizedBox(height: 10),

              if (_errorMessage.isNotEmpty) _buildErrorBox(_errorMessage),

              SizedBox(height: 20),
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                  : ElevatedButton(
                    onPressed: _login,
                    child: Text("Login", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordResetPage(),
                    ),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    bool obscureText,
    Function(String) onChanged,
  ) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.purple.shade50,
        prefixIcon: Icon(
          obscureText ? Icons.lock : Icons.person,
          color: Colors.purple.shade700,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Enter your $label";
        }
        return null;
      },
    );
  }

  Widget _buildErrorBox(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error, color: Colors.purple.shade900),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.purple.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
