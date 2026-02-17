import 'package:flutter/material.dart';
import '../../../../data/flight_data.dart';

class CitySearchScreen extends StatefulWidget {
  final String title;
  const CitySearchScreen({super.key, required this.title});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  List<CityModel> filteredCities = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCities = allCities;
  }

  void _runFilter(String enteredKeyword) {
    List<CityModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = allCities;
    } else {
      results = allCities
          .where(
            (city) =>
                city.name.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ) ||
                city.code.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      filteredCities = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value), // Filter as you type
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _runFilter('');
                        },
                      )
                    : null,
                hintText: "Where are you going?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: filteredCities.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(city.fullName),
                        subtitle: Text(city.country),
                        onTap: () => Navigator.pop(context, city.fullName),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No cities found",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
