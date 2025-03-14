// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:appdev_cc_1/models/cardclass.dart';

class Cards extends StatelessWidget {
  final List<Cardmodel> cards;
  final Function(Cardmodel) addCard;
  final Function(Cardmodel) deleteCard;

  const Cards({
    required this.cards,
    required this.addCard,
    required this.deleteCard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.question,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        card.answer,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      deleteCard(card);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await Navigator.pushNamed(context, '/addcard');
          if (newCard is Cardmodel) {
            addCard(newCard);
          }
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add),
      ),
    );
  }
}
