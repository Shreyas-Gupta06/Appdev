import 'package:app/pages/email_verification_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PhoneVerificationPage extends StatefulWidget {
  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String verificationCode = "";
  bool otpSent = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserAndSendOTP();
  }

  void _fetchUserAndSendOTP() async {
    await _authService.getUserData();
    if (AuthService.currentUser?.phone == null ||
        AuthService.currentUser!.phone!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => HomePage(
                errorMessage:
                    "Error: Phone number is missing! Please register again.",
              ),
        ),
      );
      return;
    }
    _sendOTP();
  }

  void _sendOTP() async {
    print("📨 Sending OTP to: ${AuthService.currentUser!.phone!}");
    var response = await _authService.sendPhoneOTP(
      AuthService.currentUser!.phone!,
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

  void _verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      var response = await _authService.verifyPhoneOTP(
        AuthService.currentUser!.phone!,
        verificationCode,
      );

      if (!mounted) return;

      if (response.toString().toLowerCase().contains("error")) {
        setState(() {
          errorMessage = response.toString();
        });
      } else {
        AuthService.currentUser!.phoneVerified = true;
        await storage.write(
          key: "user_data",
          value: jsonEncode(AuthService.currentUser),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Verification"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmailVerificationPage()),
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
                AuthService.currentUser?.phone ?? "No phone number available",
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
                  onPressed: _verifyPhone,
                  child: Text("Verify Phone"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
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
                style: TextButton.styleFrom(foregroundColor: Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
