import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flight_search_request.dart';

class ApiService {
  static const String baseUrl = 'http://3.11.26.231';
  static const String tokenKey = 'guest_token';

  Future<String?> getGuestToken() async {
    try {
      print('🔑 Fetching guest token...');

      final response = await http.post(
        Uri.parse('$baseUrl/fannos/api/auth/guest-token'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Token Response Status: ${response.statusCode}');
      print('📡 Token Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['guestToken'];

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);

        print('✅ Token saved: $token');
        print('⏰ Expires in: ${data['expiresIn']} seconds');
        print('💬 Message: ${data['message']}');

        return token;
      } else {
        print('❌ Failed to get token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<Map<String, dynamic>?> searchFlights(
    FlightSearchRequest request,
  ) async {
    try {
      // Get token from storage or fetch new one
      String? token = await getSavedToken();
      if (token == null || token.isEmpty) {
        token = await getGuestToken();
      }

      if (token == null) {
        print('❌ No token available');
        return null;
      }

      print('🔍 Searching flights...');
      print('📤 Request Body: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/fanno/api/flight/shopping'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      print('📡 Flight Search Status: ${response.statusCode}');
      print('📡 Flight Search Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Flight search successful!');
        return json.decode(response.body);
      } else {
        print('❌ Flight search failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error searching flights: $e');
      return null;
    }
  }
}
