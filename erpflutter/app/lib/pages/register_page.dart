import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  final User? prefilledUser; // To retain user data when coming back

  const RegisterPage({Key? key, this.prefilledUser}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  final String userType = "applicant"; // Default value
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // If prefilledUser exists, populate the form
    if (widget.prefilledUser != null) {
      firstNameController.text = widget.prefilledUser!.firstName ?? "";
      lastNameController.text = widget.prefilledUser!.lastName ?? "";
      usernameController.text = widget.prefilledUser!.username ?? "";
      emailController.text = widget.prefilledUser!.email ?? "";
      phoneController.text = widget.prefilledUser!.phone ?? "";
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

      AuthService.currentUser = newUser; // Store globally

      // Debugging: Print request details
      debugPrint("📤 Sending POST request to register user...");
      debugPrint("🔹 First Name: ${newUser.firstName}");
      debugPrint("🔹 Last Name: ${newUser.lastName}");
      debugPrint("🔹 Username: ${newUser.username}");
      debugPrint("🔹 Email: ${newUser.email}");
      debugPrint("🔹 Phone: ${newUser.phone}");
      debugPrint("🔹 User Type: ${newUser.userType}");
      debugPrint("🔹 Password: ${passwordController.text}");
      debugPrint("🔹 Confirm Password: ${password2Controller.text}");

      var response = await _authService.register(
        newUser,
        passwordController.text,
        password2Controller.text,
      );

      // Debugging: Print response details
      debugPrint("📥 Response received: $response");

      if (!mounted) return;

      if (response is Map<String, dynamic> && response.isNotEmpty) {
        debugPrint(" Registration Successful!");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration successful!")));

        // Navigate to email verification & pass user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationPage()),
        );
      } else {
        debugPrint(" Registration Failed!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed. Please try again.")),
        );
      }
    } else {
      debugPrint(" Form validation failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator:
                    (value) => value!.isEmpty ? "Enter first name" : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Enter last name" : null,
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (value) => value!.isEmpty ? "Enter username" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator:
                    (value) =>
                        RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
                            ).hasMatch(value!)
                            ? null
                            : "Enter a valid email",
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                validator:
                    (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) => value!.isEmpty ? "Enter password" : null,
              ),
              TextFormField(
                controller: password2Controller,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? "Confirm password"
                            : (value != passwordController.text
                                ? "Passwords do not match"
                                : null),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text("Register"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
