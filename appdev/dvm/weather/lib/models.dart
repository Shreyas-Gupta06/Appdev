import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

List<City> cities = [];

class City {
  String name;
  double lat;
  double lon;
  double? temperature;
  String? weatherCondition;
  String? weatherIcon;
  int? humidity;
  double? windSpeed;
  DateTime? lastUpdated;

  City({
    required this.name,
    required this.lat,
    required this.lon,
    this.temperature,
    this.weatherCondition,
    this.weatherIcon,
    this.humidity,
    this.windSpeed,
    this.lastUpdated,
  });

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      name: map['name'] ?? 'Unknown',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lon: (map['lon'] ?? 0.0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      weatherCondition: map['weatherCondition'] ?? 'Unknown',
      weatherIcon: map['weatherIcon'] ?? '',
      humidity: (map['humidity'] ?? 0).toInt(),
      windSpeed: (map['windSpeed'] ?? 0.0).toDouble(),
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.parse(map['lastUpdated'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      'temperature': temperature,
      'weatherCondition': weatherCondition,
      'weatherIcon': weatherIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

Future<void> saveCitiesToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> cityList =
      cities.map((city) => jsonEncode(city.toMap())).toList();
  await prefs.setStringList('savedCities', cityList);
}

Future<List<City>> loadCities() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? cityStrings = prefs.getStringList('savedCities');

  if (cityStrings == null || cityStrings.isEmpty) return [];
  return cityStrings.map((cityJson) {
    final map = json.decode(cityJson);
    return City.fromMap(map);
  }).toList();
}

Future<void> checkSavedCities() async {
  // test
}

Future<City?> getLastSavedCity() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? cityList = prefs.getStringList('savedCities');
  if (cityList == null || cityList.isEmpty) return null;

  final firstCityMap = jsonDecode(cityList.first);
  return City.fromMap(firstCityMap);
}

Future<City?> fetchCoordinates(String cityName) async {
  const String apiKey = '818f4d62d5d9effa00161901cf700f2d';
  final url = Uri.parse(
    'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.isEmpty) return null;

    final cityData = data[0];
    return City(
      name: cityData['name'],
      lat: cityData['lat'],
      lon: cityData['lon'],
    );
  } else {
    throw Exception('Failed to fetch city coordinates');
  }
}

Future<Map<String, dynamic>?> fetchWeatherFromLatLon(
  double lat,
  double lon,
) async {
  const String apiKey = '818f4d62d5d9effa00161901cf700f2d';
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch weather data');
  }
}

Future<void> addOrUpdateCity(City newCity) async {
  final index = cities.indexWhere((c) => c.name == newCity.name);
  if (index != -1) {
    cities[index] = newCity;
  } else {
    cities.add(newCity);
  }
  await saveCitiesToPrefs();
}

Future<void> deleteCity(String name) async {
  cities.removeWhere((city) => city.name == name);
  await saveCitiesToPrefs();
}
