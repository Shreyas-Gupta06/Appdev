import 'package:flutter/material.dart';
import 'package:appdev_cc_1/models/cardclass.dart';

class Practice extends StatefulWidget {
  final List<Cardmodel> cards;

  const Practice({required this.cards, super.key});

  @override
  State<Practice> createState() => PracticeState();
}

class PracticeState extends State<Practice> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Text("No cards available", style: TextStyle(fontSize: 24)),
      );
    }

    final card = widget.cards[_currentIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _showAnswer ? card.answer : card.question,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAnswer = true;
              });
            },
            child: Text("Show Answer"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentIndex = (_currentIndex + 1) % widget.cards.length;
                _showAnswer = false;
              });
            },
            child: Icon(Icons.arrow_forward),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
