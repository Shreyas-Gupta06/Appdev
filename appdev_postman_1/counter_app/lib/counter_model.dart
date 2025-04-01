import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Firestore references
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch counter value from API and update Firestore if successful
  Future<void> getData() async {
    try {
      final response = await http.post(
        Uri.parse('$url/$namespace/$key'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'current_value': currentValue}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentValue = data['current_value'];
        await _saveToFirestore(); // ✅ Save successful API data to Firestore
      } else {
        throw Exception('Failed to fetch data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in getData: $e');
    }
  }

  /// Increment counter via API and Firestore
  Future<void> increment() async {
    try {
      final response = await http.post(
        Uri.parse('https://letscountapi.com/$namespace/$key/increment'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        currentValue++; // Update locally
        await _saveToFirestore(); // ✅ Save updated value to Firestore
      } else {
        throw Exception('Failed to increment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in increment: $e');
    }
  }

  /// Decrement counter via API and Firestore
  Future<void> decrement() async {
    try {
      final response = await http.post(
        Uri.parse('https://letscountapi.com/$namespace/$key/decrement'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        currentValue--; // Update locally
        await _saveToFirestore(); // ✅ Save updated value to Firestore
      } else {
        throw Exception('Failed to decrement: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in decrement: $e');
    }
  }

  /// Update counter to a custom value via API and Firestore
  Future<void> updateValue(int newValue) async {
    try {
      final response = await http.post(
        Uri.parse('https://letscountapi.com/$namespace/$key/update'),
        body: jsonEncode({'current_value': newValue}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        currentValue = newValue; // Update locally
        await _saveToFirestore(); // ✅ Save updated value to Firestore
      } else {
        throw Exception('Failed to update value: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in updateValue: $e');
    }
  }

  /// Save counter data to Firestore
  Future<void> _saveToFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('counters')
          .doc('$namespace-$key')
          .set({
            'namespace': namespace,
            'key': key,
            'current_value': currentValue,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save to Firestore: $e');
    }
  }

  /// Delete counter from Firestore
  Future<void> delete() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('counters')
          .doc('$namespace-$key') // Use the counter key as document ID
          .delete();
      print("Counter deleted successfully from Firestore.");
    } catch (e) {
      throw Exception('Failed to delete from Firestore: $e');
    }
  }

  /// Fetch counters for the logged-in user from Firestore
  static Future<List<CounterModel>> fetchCountersFromFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user is signed in.');

      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('counters')
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CounterModel(
          namespace: data['namespace'],
          key: data['key'],
          currentValue: data['current_value'],
          url: '', // API URL not stored in Firestore
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch counters from Firestore: $e');
    }
  }
}
