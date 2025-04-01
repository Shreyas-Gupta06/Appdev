import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'email_verification_page.dart';
import 'home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  final AuthService _authService = AuthService();
  final String userType = "applicant"; // Default user type

  String errorMessage = ""; // Store error message globally

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data if exists
  }

  void _loadUserData() {
    if (AuthService.currentUser != null) {
      firstNameController.text = AuthService.currentUser!.firstName ?? "";
      lastNameController.text = AuthService.currentUser!.lastName ?? "";
      usernameController.text = AuthService.currentUser!.username ?? "";
      emailController.text = AuthService.currentUser!.email ?? "";
      phoneController.text = AuthService.currentUser!.phone ?? "";
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      User newUser = User(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
        email: emailController.text,
        phone: phoneController.text,
        userType: userType,
      );

      AuthService.currentUser = newUser; // Save user info

      var response = await _authService.register(
        newUser,
        passwordController.text,
        password2Controller.text,
      );

      if (!mounted) return;

      String responseString = response.toString().toLowerCase();
      if (!responseString.contains("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationPage()),
        );
      } else {
        _handleErrors(responseString);
      }
    }
  }

  void _handleErrors(String error) {
    setState(() {
      errorMessage = error.replaceAll(RegExp(r'[\[\]]'), '').trim();
    });

    // Remove the error message after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          errorMessage = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Keep it clean
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(firstNameController, "First Name"),
              _buildTextField(lastNameController, "Last Name"),
              _buildTextField(usernameController, "Username"),
              _buildTextField(emailController, "Email", email: true),
              _buildTextField(phoneController, "Phone", phone: true),
              _buildTextField(
                passwordController,
                "Password",
                obscureText: true,
              ),
              _buildTextField(
                password2Controller,
                "Confirm Password",
                obscureText: true,
              ),
              SizedBox(height: 10),

              if (errorMessage.isNotEmpty) _buildErrorBox(errorMessage),

              ElevatedButton(
                onPressed: _register,
                child: Text("Register"),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    bool email = false,
    bool phone = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
        obscureText: obscureText,
        keyboardType:
            phone
                ? TextInputType.phone
                : (email ? TextInputType.emailAddress : TextInputType.text),
        inputFormatters: phone ? [FilteringTextInputFormatter.digitsOnly] : [],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Enter $label";
          }
          if (email &&
              !RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
              ).hasMatch(value)) {
            return "Enter a valid email";
          }
          if (phone && !RegExp(r'^\d{10}$').hasMatch(value)) {
            return "Enter a valid 10-digit phone number";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildErrorBox(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.purple),
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
