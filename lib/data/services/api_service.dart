// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import '../models/guest_token_model.dart';
import '../models/flight_shopping_model.dart';
import '../models/booking_model.dart';
import '../flight_data.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://3.11.26.231/fannos';

  Future<ApiService> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'guest_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expired or invalid, try to get a new one
            await getGuestToken();
            // Retry the request
            final options = e.requestOptions;
            String? newToken = await _storage.read(key: 'guest_token');
            if (newToken != null) {
              options.headers['Authorization'] = 'Bearer $newToken';
            }
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          }
          return handler.next(e);
        },
      ),
    );

    return this;
  }

  Future<String?> getGuestToken() async {
    try {
      final response = await _dio.post('/api/auth/guest-token', data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokenResponse = GuestTokenResponse.fromJson(response.data);
        final guestToken = tokenResponse.guestToken;
        await _storage.write(key: 'guest_token', value: guestToken);
        print('✅ Guest token saved: $guestToken');
        print(
          '   Agency: ${tokenResponse.agencyType} | Expires in: ${tokenResponse.expiresIn}s | Message: ${tokenResponse.message}',
        );
        return guestToken;
      }
    } catch (e) {
      print('❌ Error getting guest token: $e');
    }
    return null;
  }

  Future<List<CityModel>> searchCities(String query) async {
    try {
      final response = await _dio.get(
        '/api/flight/search-city',
        queryParameters: {'keyword': query},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data
            .map(
              (i) => CityModel(
                name: i['name'] ?? '',
                code: i['iataCode'] ?? '',
                country: i['address']?['countryName'] ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      print('Error searching cities: $e');
    }
    return [];
  }

  Future<FlightShoppingResponse?> searchFlights(
    FlightShoppingRequest request,
  ) async {
    try {
      print('--- API POST /api/flight/shopping ---');
      print('Request body: ${request.toJson()}');
      final response = await _dio.post(
        '/api/flight/shopping',
        data: request.toJson(),
      );
      print('✅ Shopping response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final parsed = FlightShoppingResponse.fromJson(response.data);
        print('✅ Parsed ${parsed.offers.length} offers');
        return parsed;
      }
    } catch (e) {
      print('❌ Error searching flights: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getOfferPrice(OfferPriceRequest request) async {
    try {
      print('--- API POST /api/flight/offer-price ---');
      print('Request body: ${request.toJson()}');
      final response = await _dio.post(
        '/api/flight/offer-price',
        data: request.toJson(),
      );
      print('✅ Offer-price response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          print('✅ executionId: ${data['executionId']}');
          print('✅ id (fareId): ${data['id']}');
          print('✅ currency: ${data['currency']}');
          final total =
              data['pricedOffer']?['totalPrice']?['simpleCurrencyPrice']?['value'];
          print('✅ total price: $total ${data['currency']}');
          print('✅ baggageInfo: ${data['baggageInfo']}');
        }
        return response.data;
      }
    } catch (e) {
      print('❌ Error getting offer price: $e');
    }
    return null;
  }

  /// Step 3: Verify the fare with Fannos before holding.
  /// Fannos requires this call BEFORE /hold, or it returns "Booking of unverified fare is restricted."
  Future<bool> verifyFare({
    required String executionId,
    required String provider,
    required List<String> itineraryIdList,
  }) async {
    try {
      print('--- API POST /api/flight/verify ---');
      final body = {
        'executionId': executionId,
        'fareId': executionId,
        'provider': provider,
        'itineraryIdList': itineraryIdList,
      };
      print('Verify Request: $body');
      final response = await _dio.post('/api/flight/verify', data: body);
      print('Verify Response STATUS: ${response.statusCode}');
      print('Verify Response BODY: ${response.data}');
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;
        if (data is Map && data['success'] == false) {
          print('Verify rejected: ${data['message']}');
          return false; // proceed anyway — hold will give the real error
        }
        return true;
      }
    } catch (e) {
      print('verifyFare error (non-fatal): $e');
    }
    // Non-fatal — proceed to hold; let Fannos reject with a real message if needed
    return true;
  }

  Future<BookingHoldResponse?> holdBooking(BookingHoldRequest request) async {
    // Ensure we have a fresh token before the hold — Fannos returns 200 {success:false}
    // for expired tokens (not 401), so the interceptor doesn't catch it.
    await getGuestToken();
    return _doHoldBooking(request);
  }

  Future<BookingHoldResponse?> _doHoldBooking(
    BookingHoldRequest request,
  ) async {
    try {
      print('--- API POST /api/flight/hold ---');
      print('Hold Request: ${request.toJson()}');
      final response = await _dio.post(
        '/api/flight/hold',
        data: request.toJson(),
      );
      print('✅ Hold response status: ${response.statusCode}');
      print('Hold Response BODY: ${response.data}');
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        final body = response.data;
        if (body is Map && body['success'] == false) {
          final msg =
              body['message']?.toString() ??
              'Booking request rejected by server';
          throw Exception('Fannos rejected: $msg');
        }
        final holdResponse = BookingHoldResponse.fromJson(body);
        print(
          '✅ PNR: ${holdResponse.bookingLocator} | status: ${holdResponse.status} | paymentOptions: ${holdResponse.paymentOptions.length}',
        );
        return holdResponse;
      }
      throw Exception('Status $statusCode — ${response.data}');
    } on DioException catch (e) {
      var msg = e.message;
      if (e.response?.data != null) {
        print('❌ Hold DioException response body: ${e.response!.data}');
        if (e.response!.data is Map) {
          msg = e.response!.data['message'] ?? e.response!.data.toString();
        } else {
          msg = e.response!.data.toString();
        }
      }
      print('❌ Dio Error holding booking: $msg');
      throw Exception('Fannos: $msg');
    } catch (e) {
      print('❌ holdBooking error: $e');
      rethrow;
    }
  }

  Future<List<PaymentOption>> getPaymentOptions(
    BookingHoldRequest request,
  ) async {
    try {
      print('--- API POST /api/flight/hold/get-payment-options ---');
      final response = await _dio.post(
        '/api/flight/hold/get-payment-options',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'];
        if (data != null &&
            data['paymentOptions'] != null &&
            data['paymentOptions']['cards'] != null) {
          final List cards = data['paymentOptions']['cards'];
          return cards.map((i) => PaymentOption.fromJson(i)).toList();
        }
      }
    } on DioException catch (e) {
      final msg = e.response?.data != null
          ? e.response?.data.toString()
          : e.message;
      print('Dio Error: $msg');
      throw Exception(msg);
    } catch (e) {
      print('Error getting payment options: $e');
      throw Exception(e.toString());
    }
    return [];
  }

  Future<dynamic> confirmPayment(ConfirmBookingRequest request) async {
    try {
      print('--- API POST /api/flight/hold/confirmpayment ---');
      print('Confirm Request: ${request.toJson()}');
      final response = await _dio.post(
        '/api/flight/hold/confirmpayment',
        data: request.toJson(),
      );
      print('✅ Confirm payment status: ${response.statusCode}');
      if (response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final order = data['order'];
          final pnr =
              data['holdFlightBooking']?['pnr'] ??
              data['orderRes']?['flightInfo']?['pnr'] ??
              '';
          final bookingStatus =
              data['holdFlightBooking']?['bookingStatus'] ?? '';
          final traceNumber = order?['traceNumber'] ?? '';
          final statusDesc = order?['statusDesc'] ?? '';
          print(
            '✅ Confirm: pnr=$pnr | bookingStatus=$bookingStatus | payment=$statusDesc | traceNumber=$traceNumber',
          );
        }
      }
      return response.data;
    } catch (e) {
      print('❌ Error confirming payment: $e');
    }
    return null;
  }

  Future<dynamic> submitPaymentCallback(PaymentCallbackRequest request) async {
    try {
      print('--- API POST /api/flight/hold/payment-callback ---');
      print('Callback Request: ${request.toJson()}');
      final response = await _dio.post(
        '/api/flight/hold/payment-callback',
        data: request.toJson(),
      );
      print('✅ Payment callback status: ${response.statusCode}');
      print('✅ Callback response: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ Error submitting payment callback: $e');
    }
    return null;
  }
}
