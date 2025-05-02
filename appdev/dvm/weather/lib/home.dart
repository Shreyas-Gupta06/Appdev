import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkLocationPermission();
    await _checkInternet();

    if (_hasInternet) {
      if (_locationPermissionGranted) {
        await _loadWeatherFromLocation();
        setState(() {
          _selectedIndex = 0;
        });
      } else {
        setState(() {
          _selectedIndex = 1;
        });
      }
    } else {
      _initialCity = await getLastSavedCity();
      if (_initialCity != null) {
        setState(() {
          _selectedIndex = 0;
        });
      } else {
        setState(() {
          _selectedIndex = 1;
        });
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    _locationPermissionGranted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    _hasInternet = result != ConnectivityResult.none;
  }

  Future<void> _loadWeatherFromLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final city = await fetchWeatherFromLatLon(pos.latitude, pos.longitude);
      if (city != null) {
        _initialCity = City.fromMap(city);
        await addOrUpdateCity(_initialCity!);
      }
    } catch (_) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCitySelected(City city) {
    setState(() {
      _initialCity = city;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _initialCity != null
          ? Weather(city: _initialCity!)
          : const Center(child: Text("Please select a city")),
      Cities(onCitySelected: _onCitySelected),
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
