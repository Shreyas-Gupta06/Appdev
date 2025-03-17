import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home.dart';
import '../models/user.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await _authService.getUserData();
    if (user == null) {
      await _authService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _user == null
              ? Center(child: Text("No user data available."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${_user!.firstName} ${_user!.lastName}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Email: ${_user!.email}"),
                    Text("Phone: ${_user!.phone}"),
                    Text("User Type: ${_user!.userType}"),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: _logout, child: Text("Logout")),
                  ],
                ),
              ),
    );
  }
}
