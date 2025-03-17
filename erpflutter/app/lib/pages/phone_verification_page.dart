import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';

class PhoneVerificationPage extends StatefulWidget {
  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String verificationCode = "";
  bool otpSent = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  void _sendOTP() async {
    if (AuthService.currentUser?.phone == null ||
        AuthService.currentUser!.phone!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Phone number is missing!")));
      return;
    }

    var response = await _authService.sendPhoneOTP(
      AuthService.currentUser!.phone!,
    );
    if (!mounted) return;

    if (response is Map<String, dynamic> && response.isNotEmpty) {
      setState(() {
        otpSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP sent successfully!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send OTP. Try again.")));
    }
  }

  void _verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      var response = await _authService.verifyPhoneOTP(
        AuthService.currentUser!.phone!,
        verificationCode,
      );

      if (!mounted) return;

      if (response is Map<String, dynamic> && response.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Phone verified successfully!")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid verification code. Please try again."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Verification"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
              if (otpSent) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: "Verification Code"),
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
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
              TextButton(onPressed: _sendOTP, child: Text("Resend OTP")),
            ],
          ),
        ),
      ),
    );
  }
}
