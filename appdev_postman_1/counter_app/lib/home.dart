import 'package:flutter/material.dart';
import 'counter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CounterModel> counters = [];

  /// Add a new counter to the list
  void _addNewCounter(CounterModel newCounter) async {
    await newCounter.getData(); // Fetch latest value from API
    setState(() {
      counters.add(newCounter);
    });
    saveCounters(counters);
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
                    await counter.updateValue(newValue); // API call
                    setState(() {});
                    saveCounters(counters);
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

  //saving the counter data
  Future<void> saveCounters(List<CounterModel> counters) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> counterData =
        counters
            .map((c) => '${c.namespace},${c.key},${c.currentValue},${c.url}')
            .toList();
    await prefs.setStringList('counters', counterData);
  }

  //load counters from shared preferences
  Future<void> loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedData = prefs.getStringList('counters');
    if (storedData != null) {
      setState(() {
        counters =
            storedData.map((data) {
              List<String> parts = data.split(',');
              return CounterModel(
                namespace: parts[0],
                key: parts[1],
                currentValue: int.parse(parts[2]),
                url: parts[3],
              );
            }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Counters")),
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
                      await counter.decrement();
                      setState(() {});
                      saveCounters(counters);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await counter.increment();
                      setState(() {});
                      saveCounters(counters);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _updateCustomValue(counter),
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
