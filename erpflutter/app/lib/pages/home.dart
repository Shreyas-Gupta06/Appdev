import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Keep background clean
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // College Logo
              Image.asset(
                "static/college_logo.png",
                width: 120, // Adjust size
              ),
              SizedBox(height: 10),

              // College Name
              Text(
                "PATNA WOMEN'S COLLEGE",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "Autonomous\nPatna University",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 54, 164, 3),
                ),
              ),
              SizedBox(height: 5),

              // Accreditation & Certification
              Text(
                "4th Cycle NAAC A++ Accredited",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                "\"College with Potential for Excellence\" (CPE) status accorded by UGC",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "ISO 21001: 2018 certified",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 30),

              // Login & Register Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text("Register"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Theme color
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
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
