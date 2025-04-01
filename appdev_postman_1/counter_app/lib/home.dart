import 'package:flutter/material.dart';
import 'counter_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CounterModel> counters = [];

  /// Fetch counters from Firestore using CounterModel's method
  Future<void> loadCounters() async {
    List<CounterModel> fetchedCounters =
        await CounterModel.fetchCountersFromFirestore();
    setState(() {
      counters = fetchedCounters;
    });
  }

  /// Add a new counter
  void _addNewCounter(CounterModel newCounter) async {
    await newCounter.getData(); // Fetch latest value from API

    setState(() {
      counters.add(newCounter);
    });
  }

  /// Update counter with a custom value
  void _updateCustomValue(CounterModel counter) {
    TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Enter Custom Value"),
            content: TextField(
              controller: customController,
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  int? newValue = int.tryParse(customController.text);
                  if (newValue != null) {
                    await counter.updateValue(
                      newValue,
                    ); // API call to update the value
                    setState(() {});
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text("Update"),
              ),
            ],
          ),
    );
  }

  /// Show an error message using a SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadCounters(); // Load counters when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counters"),
        automaticallyImplyLeading: false, // Disable the back button
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/user',
              ); // Navigate to the user page
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: counters.length,
        itemBuilder: (context, index) {
          final counter = counters[index];
          return Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100, // ✅ Set background color
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text("${counter.namespace} / ${counter.key}"),
              subtitle: Text("Value: ${counter.currentValue}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () async {
                      try {
                        await counter.decrement();
                        setState(() {});
                      } catch (e) {
                        _showErrorMessage(e.toString());
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      try {
                        await counter.increment();
                        setState(() {});
                      } catch (e) {
                        _showErrorMessage(e.toString());
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      try {
                        _updateCustomValue(counter);
                      } catch (e) {
                        _showErrorMessage(e.toString());
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        await counter.delete(); // Delete from Firestore
                        setState(() {
                          counters.removeAt(
                            index,
                          ); // Remove locally after deletion
                        });
                      } catch (e) {
                        _showErrorMessage(e.toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCounter = await Navigator.pushNamed(context, '/add_counter');
          if (newCounter is CounterModel) {
            _addNewCounter(newCounter);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
