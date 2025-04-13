import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFrom = 'Delhi';
  String selectedTo = 'Loharu';
  DateTime selectedDate = DateTime.now();

  final List<String> locations = [
    'Delhi',
    'Pilani',
    'Loharu',
    'Jhunjhunu',
    'Jaipur',
  ];

  final List<Map<String, dynamic>> allGroups = [
    {
      'from': 'Delhi',
      'to': 'Loharu',
      'date': DateTime.now().add(const Duration(days: 1)),
      'total': 3,
      'needed': 2,
    },
    {
      'from': 'Pilani',
      'to': 'Jaipur',
      'date': DateTime.now().add(const Duration(days: 2)),
      'total': 2,
      'needed': 3,
    },
    {
      'from': 'Delhi',
      'to': 'Pilani',
      'date': DateTime.now().add(const Duration(days: 1)),
      'total': 4,
      'needed': 1,
    },
    {
      'from': 'Jhunjhunu',
      'to': 'Loharu',
      'date': DateTime.now().add(const Duration(days: 2)),
      'total': 5,
      'needed': 0,
    },
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredGroups =
        allGroups.where((group) {
          DateTime groupDate = group['date'];
          return group['from'] == selectedFrom &&
              group['to'] == selectedTo &&
              groupDate.year == selectedDate.year &&
              groupDate.month == selectedDate.month &&
              groupDate.day == selectedDate.day;
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF), // light blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFF), // soft pastel
        toolbarHeight: 90,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // From
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.location_on, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'From',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedFrom,
                  underline: Container(height: 1, color: Colors.grey),
                  style: const TextStyle(color: Colors.black),
                  items:
                      locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => selectedFrom = value!),
                ),
              ],
            ),

            // To
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.location_on, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'To',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedTo,
                  underline: Container(height: 1, color: Colors.grey),
                  style: const TextStyle(color: Colors.black),
                  items:
                      locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => selectedTo = value!),
                ),
              ],
            ),

            // Date
            GestureDetector(
              onTap: _selectDate,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 20, color: Colors.black),
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body:
          filteredGroups.isEmpty
              ? const Center(child: Text("No groups found for selection."))
              : ListView.builder(
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Future: navigate to details page
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                group['from'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                group['to'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Date: ${DateFormat('yyyy-MM-dd').format(group['date'])}",
                          ),
                          Text("Participants: ${group['total']}"),
                          Text("Needed: ${group['needed']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue[400],
        onPressed: () {
          // TODO: Open create group screen
        },
        label: const Text("Create Group"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
