import 'package:flutter/material.dart';
import 'home.dart';
import 'pages/addcard.dart';

void main() => runApp(FlashcardApp());

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      routes: {'/addcard': (context) => Addcard()},
    );
  }
}
