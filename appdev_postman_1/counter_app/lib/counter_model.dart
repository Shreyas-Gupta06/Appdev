import 'dart:convert';
import 'package:http/http.dart' as http;

class CounterModel {
  String namespace;
  String key;
  int currentValue;
  String url;

  CounterModel({
    required this.namespace,
    required this.key,
    required this.currentValue,
    required this.url,
  });

  Future<void> getData() async {
    final response = await http.post(
      Uri.parse('$url/$namespace/$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'current_value': currentValue}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentValue = data['current_value'];
    }
  }

  /// Increment counter by 1 via API
  Future<void> increment() async {
    final response = await http.post(
      Uri.parse('$url/$namespace/$key/increment'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      currentValue++; // Update locally
    }
  }

  /// Decrement counter by 1 via API
  Future<void> decrement() async {
    final response = await http.post(
      Uri.parse('$url/$namespace/$key/decrement'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      currentValue--; // Update locally
    }
  }

  /// Update counter to a custom value via API
  Future<void> updateValue(int newValue) async {
    final response = await http.post(
      Uri.parse('$url/$namespace/$key/update'),
      body: jsonEncode({'current_value': newValue}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      currentValue = newValue; // Update locally
    }
  }
}
