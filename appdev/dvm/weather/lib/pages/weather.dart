import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models.dart'; // Make sure this includes City and addOrUpdateCity

class Weather extends StatefulWidget {
  final City city;

  const Weather({super.key, required this.city});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  bool isLoading = true;
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    print('🚀 initState: Fetching weather for ${widget.city.name}');
    fetchWeather();
  }

  @override
  void didUpdateWidget(covariant Weather oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      print('🔁 City updated: ${oldWidget.city.name} -> ${widget.city.name}');
      fetchWeather();
    }
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${widget.city.lat}&lon=${widget.city.lon}&appid=818f4d62d5d9effa00161901cf700f2d&units=metric',
    );

    try {
      print(
        '🔍 Fetching weather data for ${widget.city.name}, lat=${widget.city.lat}, lon=${widget.city.lon}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Weather data fetched: $data');

        setState(() {
          weatherData = data;
          isLoading = false;
        });

        // Save or update the city in global list and prefs
        await addOrUpdateCity(widget.city);
        print('💾 City saved via addOrUpdateCity: ${widget.city.name}');
      } else {
        print('❌ Failed to fetch weather data: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❗ Error fetching weather: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch weather: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weatherData == null) {
      return const Center(child: Text('No weather data available.'));
    }

    final temp = weatherData!['main']['temp'];
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];
    final condition = weatherData!['weather'][0]['main'];
    final icon = weatherData!['weather'][0]['icon'];
    final updatedTime = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            widget.city.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Image.network(
            'http://openweathermap.org/img/wn/$icon@2x.png',
            width: 100,
            height: 100,
          ),
          Text('$temp°C', style: const TextStyle(fontSize: 40)),
          Text(condition, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Icon(Icons.opacity, size: 30),
                  const Text('Humidity'),
                  Text('$humidity%', style: const TextStyle(fontSize: 18)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.air, size: 30),
                  const Text('Wind Speed'),
                  Text('$windSpeed m/s', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Last updated: ${updatedTime.hour}:${updatedTime.minute}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
