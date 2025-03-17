import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final AuthService _authService = AuthService();
  String _email = "";
  String _otp = "";
  String _newPassword = "";
  bool _isLoading = false;
  bool _otpSent = false;

  Future<void> _sendResetOTP() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authService.requestPasswordReset(_email);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response["error"]}")));
    } else {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP sent to your email.")));
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authService.resetPassword(
      _email,
      _otp,
      _newPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response["error"]}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset successful. Please log in.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => _email = value,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            SizedBox(height: 20),
            _otpSent
                ? Column(
                  children: [
                    TextField(
                      onChanged: (value) => _otp = value,
                      decoration: InputDecoration(labelText: "Enter OTP"),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => _newPassword = value,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Enter new password",
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _resetPassword,
                          child: Text("Reset Password"),
                        ),
                  ],
                )
                : _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _sendResetOTP,
                  child: Text("Send OTP"),
                ),
          ],
        ),
      ),
    );
  }
}
