import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'add_counter.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      routes: {
        '/': (context) => HomePage(),
        '/sign-in': (context) => SignInScreenWidget(),
        '/add_counter': (context) => AddCounterPage(),
        '/user': (context) => UserPage(),
      },
    );
  }
}

class SignInScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        GoogleProvider(
          clientId:
              "130075632131-mghe0efcurf0bsv59riu23qtg58ervqs.apps.googleusercontent.com",
        ),
      ],
      showAuthActionSwitch: false, // Optional, removes email/password toggle
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          // Get the current user
          // User? user = FirebaseAuth.instance.currentUser;

          // // Print user details to the console
          // if (user != null) {
          //   print("User signed in:");
          //   print("UID: ${user.uid}");
          //   print("Email: ${user.email}");
          //   print("Display Name: ${user.displayName}");

          // } else {
          //   print("No user is signed in.");
          // }

          // Navigate to the home page
          Navigator.pushReplacementNamed(context, '/');
        }),
      ],
    );
  }
}
