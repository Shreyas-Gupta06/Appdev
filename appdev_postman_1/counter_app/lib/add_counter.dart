import 'package:flutter/material.dart';
import 'counter_model.dart';

class AddCounterPage extends StatelessWidget {
  const AddCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    String namespace = "";
    String key = "";
    String value = "";

    void _showErrorMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Counter"),
        backgroundColor: Colors.blue.shade900, // Dark blue AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Namespace"),
              onChanged: (text) => namespace = text,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Key"),
              onChanged: (text) => key = text,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Initial Value"),
              keyboardType: TextInputType.number,
              onChanged: (text) => value = text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue.shade100, // Match button color to theme
              ),
              onPressed: () {
                if (namespace.isEmpty) {
                  _showErrorMessage("Namespace cannot be empty.");
                  return;
                }
                if (key.isEmpty) {
                  _showErrorMessage("Key cannot be empty.");
                  return;
                }
                int? initialValue = int.tryParse(value);
                if (initialValue == null) {
                  _showErrorMessage("Initial Value must be a valid number.");
                  return;
                }

                CounterModel newCounter = CounterModel(
                  namespace: namespace,
                  key: key,
                  currentValue: initialValue,
                  url: "https://letscountapi.com",
                );
                Navigator.pop(context, newCounter);
              },
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
