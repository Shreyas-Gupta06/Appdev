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
    print('🏁 Cities initState');
    _loadCities();
  }

  Future<void> _loadCities() async {
    print('📦 Loading saved cities...');
    cities = await loadCities(); // Update global list
    print('✅ Loaded ${cities.length} saved cities');
    setState(() {});
  }

  Future<void> _searchCity(String query) async {
    searchQuery = query;
    print('🔍 Searching for city: "$query"');
    if (query.isEmpty) {
      print('❗ Query is empty. Clearing results.');
      setState(() => searchResults.clear());
      return;
    }

    City? city = await fetchCoordinates(query);
    if (city != null) {
      print('✅ Found city: ${city.name}, lat=${city.lat}, lon=${city.lon}');
      setState(() => searchResults = [city]);
    } else {
      print('❌ No city found for query: "$query"');
      setState(() => searchResults.clear());
    }
  }

  Future<void> _addCity(City city) async {
    print('➕ Attempting to add/update city: ${city.name}');
    await addOrUpdateCity(city); // Adds to global list and saves to prefs
    setState(() {
      searchResults.clear();
      searchQuery = '';
    });
  }

  Future<void> _deleteCity(int index) async {
    final city = cities[index];
    print('🗑️ Deleting city: ${city.name}');
    await deleteCity(city.name); // Removes from global list and prefs
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('🧱 Building Cities widget');
    return Container(
      color: Colors.blueGrey[50], // Background color
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onSubmitted: _searchCity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search for a city...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        searchResults.clear();
                        print('❌ Cleared search');
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔎 Search result section
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final city = searchResults[index];
                    return Card(
                      color: Colors.white,
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
                          print('📌 Selected search result: ${city.name}');
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

            // 🏙️ Saved cities
            const Divider(thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Saved Cities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6,
                    ),
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
                        print('👉 Selected saved city: ${city.name}');
                        widget.onCitySelected(city);
                      },
                    ),
                  );
                },
              ),
            ),

            // 🔁 Debug button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.indigo),
              onPressed: checkSavedCities,
            ),
          ],
        ),
      ),
    );
  }
}
