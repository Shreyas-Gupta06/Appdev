import 'package:flutter/material.dart';
import 'counter_model.dart';

class AddCounterPage extends StatelessWidget {
  const AddCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    String namespace = "";
    String key = "";
    String value = "";

    return Scaffold(
      appBar: AppBar(title: Text("Add Counter")),
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
              onPressed: () {
                int? initialValue = int.tryParse(value);
                if (namespace.isNotEmpty &&
                    key.isNotEmpty &&
                    initialValue != null) {
                  CounterModel newCounter = CounterModel(
                    namespace: namespace,
                    key: key,
                    currentValue: initialValue,
                    url: "https://letscountapi.com",
                  );
                  Navigator.pop(context, newCounter);
                }
              },
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
