import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pages/home.dart';
import 'pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final String baseUrl = "http://srijansahay05.in/api/users/";

  Future<Widget> _checkAuthStatus() async {
    String? refreshToken = await storage.read(key: "refresh_token");
    if (refreshToken == null) {
      return HomePage();
    }

    final response = await http.post(
      Uri.parse("${baseUrl}token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "access_token", value: data['access']);
      return DashboardPage();
    } else {
      await storage.deleteAll();
      return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          return MaterialApp(home: snapshot.data ?? HomePage());
        }
      },
    );
  }
}
