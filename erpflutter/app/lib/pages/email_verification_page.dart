import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'phone_verification_page.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String verificationCode = "";
  bool otpSent = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndVerifyEmail();
  }

  final FlutterSecureStorage storage = FlutterSecureStorage();

  void _fetchUserDataAndVerifyEmail() async {
    await _authService.getUserData(); // Fetch latest user data
    if (AuthService.currentUser?.email == null ||
        AuthService.currentUser!.email!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => HomePage(
                errorMessage: "Error: Email is missing! Please register again.",
              ),
        ),
      );
      return;
    }
    _sendOTP();
  }

  void _sendOTP() async {
    print("📨 Sending OTP to: ${AuthService.currentUser!.email!}");

    var response = await _authService.sendEmailOTP(
      AuthService.currentUser!.email!,
    );

    if (!mounted) return;

    setState(() {
      if (response.toString().toLowerCase().contains("error")) {
        errorMessage = response.toString();
      } else {
        otpSent = true;
        errorMessage = null;
      }
    });
  }

  void _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      var response = await _authService.verifyEmailOTP(
        AuthService.currentUser!.email!,
        verificationCode,
      );

      if (!mounted) return;

      if (response.toString().toLowerCase().contains("error")) {
        setState(() {
          errorMessage = response.toString();
        });
      } else {
        AuthService.currentUser!.emailVerified = true;

        // ✅ Perform async work outside setState()
        await storage.write(
          key: "user_data",
          value: jsonEncode(AuthService.currentUser),
        );

        if (!mounted) return;

        // ✅ Navigate safely using Future.microtask()
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneVerificationPage()),
          );
        });

        setState(() {}); // ✅ Only update the UI synchronously if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email Verification"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A verification code has been sent to:",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                AuthService.currentUser?.email ?? "No email available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              if (errorMessage != null)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              if (otpSent) ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Verification Code",
                    labelStyle: TextStyle(color: Colors.purple),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.purple.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.purple.shade50,
                  ),
                  onChanged: (value) => verificationCode = value,
                  validator:
                      (value) =>
                          value!.isEmpty ? "Enter verification code" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyEmail,
                  child: Text("Verify Email"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              TextButton(
                onPressed: _sendOTP,
                child: Text("Resend OTP"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
