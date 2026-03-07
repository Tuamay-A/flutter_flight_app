import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/flight_search_request.dart';

class FlightSearchExample extends StatefulWidget {
  const FlightSearchExample({super.key});

  @override
  State<FlightSearchExample> createState() => _FlightSearchExampleState();
}

class _FlightSearchExampleState extends State<FlightSearchExample> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _testApiService() async {
    setState(() => _isLoading = true);

    print('\n========== API SERVICE DEMO ==========\n');

    // Create request using model
    final request = FlightSearchRequest(
      originDestinations: [
        OriginDestination(
          departure: Location(airportCode: 'DXB', date: '2026-04-20'),
          arrival: Location(airportCode: 'ADD'),
        ),
        OriginDestination(
          departure: Location(airportCode: 'ADD', date: '2026-04-08'),
          arrival: Location(airportCode: 'DXB'),
        ),
      ],
      travellers: Travellers(adt: 1, chd: 0, inf: 0),
    );

    final result = await _apiService.searchFlights(request);

    if (result != null) {
      print('\n✅ SUCCESS! Check console for all details\n');
    } else {
      print('\n❌ FAILED! Check console for errors\n');
    }

    print('========== END OF DEMO ==========\n');

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Service Demo')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _testApiService,
                child: const Text('Test Flight Search API'),
              ),
      ),
    );
  }
}
