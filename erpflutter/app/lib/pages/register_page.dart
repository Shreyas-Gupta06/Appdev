import '../models/user.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // GlobalKey to manage form state
  final _formKey = GlobalKey<FormState>();

  // Variables to store input values
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? phone;
  String password = "";
  String password2 = "";
  final String userType = "applicant"; // Default value

  AuthService authService = AuthService(); // Create an instance

  void _register() async {
    if (_formKey.currentState!.validate()) {
      User newUser = User(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
        userType: userType,
      );

      // Call the register function with the User object and passwords
      var response = await authService.register(newUser, password, password2);
      if (!mounted) return; // Ensure widget is still in the tree

      if (response is Map<String, dynamic> && response.isNotEmpty) {
        // Check if response is not null
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration successful!")));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(userData: response),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed. Please try again.")),
        );
      }
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
                initialValue: firstName,
                decoration: InputDecoration(labelText: "First Name"),
                onChanged: (value) => setState(() => firstName = value),
                validator:
                    (value) => value!.isEmpty ? "Enter first name" : null,
              ),
              TextFormField(
                initialValue: lastName,
                decoration: InputDecoration(labelText: "Last Name"),
                onChanged: (value) => setState(() => lastName = value),
                validator: (value) => value!.isEmpty ? "Enter last name" : null,
              ),
              TextFormField(
                initialValue: username,
                decoration: InputDecoration(labelText: "Username"),
                onChanged: (value) => setState(() => username = value),
                validator: (value) => value!.isEmpty ? "Enter username" : null,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (value) => setState(() => email = value),
                validator:
                    (value) =>
                        RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\$',
                            ).hasMatch(value!)
                            ? null
                            : "Enter a valid email",
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (value) => setState(() => phone = value),
                validator:
                    (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                onChanged: (value) => setState(() => password = value),
                validator: (value) => value!.isEmpty ? "Enter password" : null,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
                onChanged: (value) => setState(() => password2 = value),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? "Confirm password"
                            : (value != password
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
