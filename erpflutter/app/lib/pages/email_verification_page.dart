import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'phone_verification_page.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String verificationCode = "";
  bool otpSent = false;
  String? errorMessage; // Stores persistent error messages

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  void _sendOTP() async {
    if (AuthService.currentUser?.email == null ||
        AuthService.currentUser!.email!.isEmpty) {
      setState(() {
        errorMessage = "Email is missing!";
      });
      return;
    }

    print("📨 Sending OTP to: ${AuthService.currentUser!.email!}");

    var response = await _authService.sendEmailOTP(
      AuthService.currentUser!.email!,
    );

    print("🔍 OTP API Response: $response");

    if (!mounted) return;

    String responseString = response.toString().toLowerCase();

    setState(() {
      if (responseString.contains("error")) {
        errorMessage = responseString;
      } else if (response is Map<String, dynamic> && response.isNotEmpty) {
        otpSent = true;
        errorMessage = null; // Clear previous errors on success
      } else {
        errorMessage = "Failed to send OTP. Try again.";
      }
    });
  }

  void _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      print(
        "✅ Verifying OTP: $verificationCode for ${AuthService.currentUser!.email}",
      );

      var response = await _authService.verifyEmailOTP(
        AuthService.currentUser!.email!,
        verificationCode,
      );

      print("🔍 OTP Verification Response: $response");

      if (!mounted) return;

      String responseString = response.toString().toLowerCase();

      setState(() {
        if (responseString.contains("error")) {
          errorMessage = responseString;
        } else if (response is Map<String, dynamic> && response.isNotEmpty) {
          errorMessage = null; // Clear errors on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneVerificationPage()),
          );
        } else {
          errorMessage = "Invalid verification code. Please try again.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email Verification"),
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

              // Display the error message in a red box if an error exists
              if (errorMessage != null)
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
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
                  decoration: InputDecoration(labelText: "Verification Code"),
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
