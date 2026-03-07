import 'package:expedia/pages/home/auth/auth_controller.dart';
import 'package:expedia/pages/home/auth/sign_in_page.dart';
import 'package:expedia/services/api_service.dart';
import 'package:expedia/models/flight_search_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/account/controllers/setting_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  
  // Get guest token
  String? token = await apiService.getGuestToken();
  print('\n🎫 Token generated: $token\n');
  
  // Sample flight search
  final request = FlightSearchRequest(
    originDestinations: [
      OriginDestination(
        departure: Location(airportCode: 'DXB', date: '2026-04-20'),
        arrival: Location(airportCode: 'ADD'),
      ),
      OriginDestination(
        departure: Location(airportCode: 'ADD', date: '2026-04-25'),
        arrival: Location(airportCode: 'DXB'),
      ),
    ],
    travellers: Travellers(adt: 1, chd: 0, inf: 0),
  );
  
  final result = await apiService.searchFlights(request);
  print('\n✈️ Flight search completed!\n');
  
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final settingsController = Get.put(SettingsController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        theme: ThemeData.light().copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF0B0F1A),
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        themeMode: settingsController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SignInPage(),
      ),
    );
  }
}
