import 'package:flutter/material.dart';
import '../models.dart';

class Cities extends StatefulWidget {
  final Function(City) onCitySelected;

  const Cities({super.key, required this.onCitySelected});

  @override
  State<Cities> createState() => _CitiesState();
}

class _CitiesState extends State<Cities> {
  List<City> searchResults = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadCities();
  }

  Future<void> _loadCities() async {
    cities = await loadCities(); // Update global list

    setState(() {});
  }

  Future<void> _searchCity(String query) async {
    searchQuery = query;

    if (query.isEmpty) {
      setState(() => searchResults.clear());
      return;
    }

    City? city = await fetchCoordinates(query);
    if (city != null) {
      setState(() => searchResults = [city]);
    } else {
      setState(() => searchResults.clear());
    }
  }

  Future<void> _addCity(City city) async {
    await addOrUpdateCity(city); // Adds to global list and saves to prefs
    setState(() {
      searchResults.clear();
      searchQuery = '';
    });
  }

  Future<void> _deleteCity(int index) async {
    final city = cities[index];

    await deleteCity(city.name); // Removes from global list and prefs
    setState(() {});
  }

  Future<void> _checkSavedCities() async {
    await checkSavedCities(); // Call the checkSavedCities function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cities',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onSubmitted: _searchCity,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search for a city...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          searchResults.clear();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results Section
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final city = searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(city.name),
                      leading: const Icon(
                        Icons.location_city,
                        color: Colors.blueAccent,
                      ),
                      trailing: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                      ),
                      onTap: () {
                        _addCity(city);
                      },
                    ),
                  );
                },
              ),
            )
          else if (searchQuery.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'No city found.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),

          // Saved Cities Section
          const Divider(thickness: 1),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved Cities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(city.name),
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.orange,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCity(index),
                            ),
                            onTap: () {
                              widget.onCitySelected(city);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          //test
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _checkSavedCities,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Check Saved Cities'),
            ),
          ),
        ],
      ),
    );
  }
}
