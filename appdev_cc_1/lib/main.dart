import 'package:flutter/material.dart';

void main() {
  runApp(FlashcardApp()); // Root widget of the application
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FlashcardHome());
  }
}

class FlashcardHome extends StatefulWidget {
  @override
  _FlashcardHomeState createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  int _selectedIndex = 0; // Tracks selected bottom navigation index

  void _onItemTapped(int index) {
    // function to determine which page to be shown
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    FlashcardPage(),
    CardListPage(),
  ]; // List of pages to switch between

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FLASHCARD",
          style: TextStyle(fontFamily: 'Comic Sans', fontSize: 18),
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body:
          _pages[_selectedIndex], //function being used to switch between pages
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
}

class FlashcardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                "Title",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text("Show Answer"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.arrow_forward),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class CardListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      //Stack widget allows you to place its children on top of each other
      children: [
        GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                //Stack widget allows you to place its children on top of each other
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Question",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "Answer",
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
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
            backgroundColor: Colors.deepOrange,
          ),
        ),
      ],
    );
  }
}
