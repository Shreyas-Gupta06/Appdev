import 'package:flutter/material.dart';
import 'pages/cards.dart';
import 'pages/practice.dart';
import 'models/cardclass.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Cardmodel> cards = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Cards(cards: cards, addCard: addCard, deleteCard: deleteCard),
      Practice(cards: cards),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FLASHCARD",
          style: TextStyle(fontFamily: 'Comic Sans', fontSize: 18),
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel),
            label: "CARDS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: "PRACTICE",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  void addCard(Cardmodel card) {
    setState(() {
      cards.add(card);
    });
  }

  void deleteCard(Cardmodel card) {
    setState(() {
      cards.remove(card);
    });
  }
}
