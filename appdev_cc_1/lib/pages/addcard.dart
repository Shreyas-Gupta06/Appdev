import 'package:flutter/material.dart';
import 'package:appdev_cc_1/models/cardclass.dart';

class Addcard extends StatelessWidget {
  const Addcard({super.key});

  @override
  Widget build(BuildContext context) {
    String question = "";
    String answer = "";

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Card"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Question"),
              onChanged: (text) => question = text,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Answer"),
              onChanged: (text) => answer = text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (question.isNotEmpty && answer.isNotEmpty) {
                  Cardmodel newCard = Cardmodel(
                    question: question,
                    answer: answer,
                  );
                  Navigator.pop(context, newCard);
                }
              },
              child: Text("Done"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
