import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models.dart'; // Contains City model, fetchWeatherFromLatLon, and saveCityToPrefs
import 'pages/weather.dart';
import 'pages/cities.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _locationPermissionGranted = false;
  bool _hasInternet = true;
  City? _initialCity;

  @override
  void initState() {
    super.initState();
    print('🔁 initState called');
    _initialize();
  }

  Future<void> _initialize() async {
    print('🚀 Starting _initialize');

    await _checkLocationPermission();
    await _checkInternet();

    if (_hasInternet) {
      print('📡 Internet is available');
      if (_locationPermissionGranted) {
        print('📍 Location permission granted');
        await _loadWeatherFromLocation();
        print('✅ Weather loaded from location');
        setState(() {
          _selectedIndex = 0;
        });
      } else {
        print('❌ Location permission NOT granted');
        setState(() {
          _selectedIndex = 1;
        });
      }
    } else {
      print('⚠️ No internet connection');
      _initialCity = await getLastSavedCity(); // Get last saved city
      if (_initialCity != null) {
        print('💾 Loaded city from SharedPreferences: ${_initialCity!.name}');
        setState(() {
          _selectedIndex = 0;
        });
      } else {
        print('❌ No saved city found in SharedPreferences');
        setState(() {
          _selectedIndex = 1;
        });
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    print('🔍 Checking location permission...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('⚠️ Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
    }
    _locationPermissionGranted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    print('📌 Location permission status: $_locationPermissionGranted');
  }

  Future<void> _checkInternet() async {
    print('🌐 Checking internet connectivity...');
    final result = await Connectivity().checkConnectivity();
    _hasInternet = result != ConnectivityResult.none;
    print('🔗 Internet connectivity result: $_hasInternet');
  }

  Future<void> _loadWeatherFromLocation() async {
    try {
      print('📍 Getting current location...');
      final pos = await Geolocator.getCurrentPosition();
      print('📌 Position: lat=${pos.latitude}, lon=${pos.longitude}');
      final city = await fetchWeatherFromLatLon(pos.latitude, pos.longitude);
      print("📦 Raw data from fetchWeatherFromLatLon: $city");

      if (city != null) {
        _initialCity = City.fromMap(city); // Convert Map to City
        await addOrUpdateCity(_initialCity!); // Use addOrUpdateCity function
        print('🌦️ Weather data fetched and saved for: ${_initialCity!.name}');
      } else {
        print('❌ City fetch returned null');
      }
    } catch (e) {
      print('❗ Failed to load weather: $e');
    }
  }

  void _onItemTapped(int index) {
    print('🖱️ BottomNav tapped: index=$index');
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCitySelected(City city) {
    print('🏙️ City selected from Cities page: ${city.name}');
    setState(() {
      _initialCity = city;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🧱 Building HomePage widget, selectedIndex=$_selectedIndex');
    final pages = [
      _initialCity != null
          ? Weather(city: _initialCity!) // Weather page
          : const Center(
            child: Text("Please select a city"),
          ), // Default message
      Cities(onCitySelected: _onCitySelected), // Cities page
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Cities',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
