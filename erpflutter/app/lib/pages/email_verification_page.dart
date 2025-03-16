import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'phone_verification_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EmailVerificationPage({required this.userData});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  String verificationCode = "";
  bool otpSent = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  AuthService authService = AuthService();

  void _sendOTP() async {
    var response = await authService.sendEmailOTP(widget.userData['email']);
    if (!mounted) return; // Ensure widget is still in the tree

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

  void _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      var response = await authService.verifyEmailOTP(
        widget.userData['email'],
        verificationCode,
      );
      if (!mounted) return; // Ensure widget is still in the tree

      if (response is Map<String, dynamic> && response.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Email verified successfully!")));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PhoneVerificationPage(userData: widget.userData),
          ),
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
        title: Text("Email Verification"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, widget.userData);
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
                widget.userData['email'],
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
