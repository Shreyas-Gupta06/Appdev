import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.blue.shade100, // Light blue AppBar
        elevation: 0, // Flat AppBar for a cleaner look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information Section
            if (user != null) ...[
              Text(
                "Name:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(user.displayName ?? 'N/A', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(
                "UID:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(user.uid, style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(
                "Email:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(user.email ?? 'N/A', style: TextStyle(fontSize: 18)),
            ] else ...[
              Center(
                child: Text(
                  "No user is currently logged in.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
            Spacer(), // Pushes the logout button to the bottom
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background
                  foregroundColor: Colors.white, // White text
                  padding: EdgeInsets.symmetric(vertical: 12), // Smaller size
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to sign-in page after signing out
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                icon: Icon(Icons.logout),
                label: Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
