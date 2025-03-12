import 'package:flutter/material.dart';
import 'home.dart';
import 'add_counter.dart';

void main() => runApp(
  MaterialApp(
    routes: {
      '/': (context) => HomePage(),
      '/add_counter': (context) => AddCounterPage(),
    },
  ),
);
