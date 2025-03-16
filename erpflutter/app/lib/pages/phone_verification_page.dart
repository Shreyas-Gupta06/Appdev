import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PhoneVerificationPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  PhoneVerificationPage({required this.userData});

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // Instance of AuthService

  String verificationCode = "";
  bool otpSent = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  void _sendOTP() async {
    var response = await _authService.sendPhoneOTP(widget.userData['phone']);
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

  void _verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      var response = await _authService.verifyPhoneOTP(
        widget.userData['phone'],
        verificationCode,
      );
      if (!mounted) return; // Ensure widget is still in the tree

      if (response is Map<String, dynamic> && response.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Phone verified successfully!")));
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(userData: widget.userData),
          ),
        )
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
                widget.userData['phone'],
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
