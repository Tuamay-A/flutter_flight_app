// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:expedia/pages/home/flights/OnewayPage/models/seat_model.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/models/flight_shopping_model.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/airport_model.dart';
import '../../../../data/services/airport_service.dart';
import '../OnewayPage/models/one_way_models.dart';
import '../../../../data/models/passenger_model.dart';
import '../roundtrip/models/round_trip_models.dart';

class FlightController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AirportSearchService airportService = Get.find<AirportSearchService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Search Results
  var flightOffers = <FlightOffer>[].obs;

  // Fannos Specific State
  var executionId = ''.obs;
  var itineraryIdList = <String>[].obs;
  var currentOfferItems = <OfferItem>[].obs;
  var lastSearchRequest = Rxn<FlightShoppingRequest>();

  // Selected Offer and Booking
  var selectedDepartureOffer = Rxn<FlightOffer>();
  var selectedReturnOffer = Rxn<FlightOffer>();
  var bookingLocator = ''.obs;
  var paymentOptions = <PaymentOption>[].obs;

  // Airport Search Results
  var searchResultsAirports = <AirportModel>[].obs;
  var isSearchingAirports = false.obs;

  // Search Query for Debouncing
  var currentSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(currentSearchQuery, (String query) {
      if (query.isEmpty) {
        searchResultsAirports.assignAll([]);
        isSearchingAirports.value = false;
        return;
      }
      if (query.length >= 2) {
        _performSearch(query);
      } else {
        searchResultsAirports.assignAll([]);
        isSearchingAirports.value = false;
      }
    }, time: const Duration(milliseconds: 500));
  }

  void searchAirports(String query) {
    if (query.isEmpty) {
      searchResultsAirports.assignAll([]);
      isSearchingAirports.value = false;
    } else {
      isSearchingAirports.value = true;
      currentSearchQuery.value = query;
    }
  }

  void _performSearch(String query) {
    final results = airportService.searchAirports(query);
    searchResultsAirports.assignAll(results);
    isSearchingAirports.value = false;
  }

  // Detailed Offer (Fares, FQ, etc)
  var currentOfferPriceDetail = Rxn<Map<String, dynamic>>();

  Future<void> searchFlights(FlightShoppingRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      lastSearchRequest.value = request;

      final response = await _apiService.searchFlights(request);
      if (response != null) {
        flightOffers.value = response.offers;
        print('✅ Flight Shopping: ${response.offers.length} offers received');
        for (int i = 0; i < response.offers.length; i++) {
          final o = response.offers[i];
          print(
            '  [$i] offerId=${o.id} | provider=${o.provider} | airline=${o.airline} | total=${o.price.total} ${o.price.currency} | productIds=${o.itineraryIdList}',
          );
        }
      } else {
        errorMessage.value = 'Failed to fetch flights. Please try again.';
        print('❌ Flight Shopping: response was null');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Flight Shopping error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectOffer(FlightOffer offer) async {
    try {
      isLoading.value = true;
      currentOfferPriceDetail.value = null;
      selectedDepartureOffer.value = offer;

      // itineraryIdList = flights[].productId  (NOT segment ids)
      final ids = offer.itineraryIdList;
      itineraryIdList.assignAll(ids);
      print('itineraryIdList: $ids');

      // Build OfferItem with all required Fannos fields
      final offerItem = OfferItem(
        offerId: offer.id,
        offerItemId: offer.offerItemId ?? offer.id,
        owner: offer.provider ?? 'CP',
        baggageAllowance: offer.baggageServices.map((b) => b.toJson()).toList(),
        baseAmount: offer.price.baseFare,
        taxAmount: offer.price.taxes,
        totalAmount: offer.price.total,
        currency: offer.price.currency,
      );
      currentOfferItems.assignAll([offerItem]);

      final priceRequest = OfferPriceRequest(
        executionId: offer.id,
        provider: offer.provider ?? 'CP',
        offerItems: currentOfferItems,
        itineraryIdList: ids,
        travellers: lastSearchRequest.value?.travellers ?? Travellers(adt: 1),
        originDestinations: lastSearchRequest.value?.originDestinations ?? [],
      );

      final response = await _apiService.getOfferPrice(priceRequest);
      if (response != null && response['data'] != null) {
        currentOfferPriceDetail.value = response;
        final data = response['data'];
        // Per Postman: executionId = response.data.executionId, fareId = response.data.id
        executionId.value =
            data['executionId']?.toString() ??
            data['fareId']?.toString() ??
            data['id']?.toString() ??
            offer.id;
        print('✅ executionId from offer-price: ${executionId.value}');
        // Log price details from pricedOffer
        final total =
            data['pricedOffer']?['totalPrice']?['simpleCurrencyPrice']?['value'];
        final currency = data['currency'] ?? offer.price.currency;
        print('✅ Confirmed price: $total $currency');
        print('✅ Baggage info: ${data['baggageInfo']}');
      } else {
        executionId.value = offer.id;
        print(
          '⚠️ offer-price returned null, fallback executionId: ${executionId.value}',
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to load offer details: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Price Getters ───
  double get currentGrandTotal {
    final detail = currentOfferPriceDetail.value;
    if (detail != null && detail['data'] != null) {
      final data = detail['data'];
      // Try pricedOffer path first (actual offer-price response structure)
      final fromPricedOffer =
          data['pricedOffer']?['totalPrice']?['simpleCurrencyPrice']?['value'];
      if (fromPricedOffer != null) {
        return double.tryParse(fromPricedOffer.toString()) ?? 0.0;
      }
      // Fallback to flat pricing
      return double.tryParse(data['pricing']?['total']?.toString() ?? '0') ??
          0.0;
    }
    final offer = selectedDepartureOffer.value;
    if (offer != null) {
      return double.tryParse(offer.price.total) ?? 0.0;
    }
    return 0.0;
  }

  double get currentBasePrice {
    final detail = currentOfferPriceDetail.value;
    if (detail != null && detail['data'] != null) {
      final data = detail['data'];
      final fromPricedOffer =
          data['pricedOffer']?['offerItem']?[0]?['totalPriceDetail']?['baseAmount']?['value'];
      if (fromPricedOffer != null) {
        return double.tryParse(fromPricedOffer.toString()) ?? 0.0;
      }
      return double.tryParse(data['pricing']?['baseFare']?.toString() ?? '0') ??
          0.0;
    }
    return double.tryParse(
          selectedDepartureOffer.value?.price.baseFare ?? '0',
        ) ??
        0.0;
  }

  double get currentTotalTax {
    final detail = currentOfferPriceDetail.value;
    if (detail != null && detail['data'] != null) {
      final data = detail['data'];
      final fromPricedOffer =
          data['pricedOffer']?['offerItem']?[0]?['totalPriceDetail']?['taxes']?['total']?['value'];
      if (fromPricedOffer != null) {
        return double.tryParse(fromPricedOffer.toString()) ?? 0.0;
      }
      return double.tryParse(data['pricing']?['taxes']?.toString() ?? '0') ??
          0.0;
    }
    return double.tryParse(selectedDepartureOffer.value?.price.taxes ?? '0') ??
        0.0;
  }

  // ─── Mapping API JSON to UI Models ───
  // ... (Keeping the UI helpers similar for compatibility)

  List<FareOption> getFaresFromApi() {
    // Always return fares — the Obx wrapper ensures reactive update
    // when currentOfferPriceDetail loads, but we must not return [] (blank page)
    final _ = currentOfferPriceDetail.value;
    return [
      FareOption(
        name: 'Standard Economy',
        description: 'Class: Economy',
        priceMultiplier: 1.0,
        features: [
          const FareFeature(
            text: 'Personal item included',
            type: FareFeatureType.included,
          ),
          const FareFeature(
            text: 'Carry-on bag included',
            type: FareFeatureType.included,
          ),
          const FareFeature(
            text: 'Standard seat assigned',
            type: FareFeatureType.included,
          ),
        ],
      ),
    ];
  }

  List<List<SeatInfo>> getSeatMapFromApi() {
    final rows = <List<SeatInfo>>[];
    final cols = ['A', 'B', 'C', '', 'D', 'E', 'F'];
    for (int row = 1; row <= 20; row++) {
      final seats = <SeatInfo>[];
      for (final col in cols) {
        if (col.isEmpty) {
          seats.add(const SeatInfo(label: '', type: SeatType.available));
          continue;
        }
        seats.add(SeatInfo(label: '$row$col', type: SeatType.available));
      }
      rows.add(seats);
    }
    return rows;
  }

  List<BaggageOption> getBaggageFromApi() {
    return [
      const BaggageOption(
        label: 'No checked bags',
        description: 'API Default',
        price: 0,
        bags: 0,
      ),
      const BaggageOption(
        label: '1 checked bag',
        description: 'Up to 23kg',
        price: 40,
        bags: 1,
      ),
    ];
  }

  // Round-trip aliases for compatibility
  List<RtFareOption> getRtFaresFromApi() {
    // Access observable to satisfy Obx
    final _ = currentOfferPriceDetail.value;
    return [
      const RtFareOption(
        name: 'Standard Economy',
        description: 'Class: Economy',
        priceMultiplier: 1.0,
        features: [
          RtFareFeature(
            text: 'Personal item included',
            type: RtFareFeatureType.included,
          ),
          RtFareFeature(
            text: 'Carry-on bag included',
            type: RtFareFeatureType.included,
          ),
          RtFareFeature(
            text: 'Standard seat assigned',
            type: RtFareFeatureType.included,
          ),
        ],
      ),
    ];
  }

  List<List<SeatInfo>> getRtSeatMapFromApi([bool isReturn = false]) =>
      getSeatMapFromApi();

  List<RtBaggageOption> getRtBaggageFromApi() {
    // Access observable to satisfy Obx
    final _ = currentOfferPriceDetail.value;
    return [
      const RtBaggageOption(
        label: 'No checked bags',
        description: 'API Default',
        price: 0,
        bags: 0,
      ),
      const RtBaggageOption(
        label: '1 checked bag',
        description: 'Up to 23kg',
        price: 40,
        bags: 1,
      ),
    ];
  }

  // ─── Booking Flow ───

  Future<bool> startBooking(List<Passenger> passengers) async {
    try {
      isLoading.value = true;

      print(
        'startBooking: executionId="${executionId.value}" offerItems=${currentOfferItems.length} itineraryIds=$itineraryIdList',
      );
      final provider = selectedDepartureOffer.value?.provider ?? 'QR';

      final holdRequest = BookingHoldRequest(
        executionId: executionId.value,
        offerPriceId: executionId.value,
        provider: provider,
        offerItems: currentOfferItems,
        customerInfos: passengers,
        travellers: lastSearchRequest.value?.travellers ?? Travellers(adt: 1),
        verifyRequest: {
          'fareId': executionId.value,
          'itineraryIdList': itineraryIdList,
        },
      );

      // Step 3 (Postman): Verify the fare BEFORE holding
      // Fannos requires this or it returns "Booking of unverified fare is restricted"
      await _apiService.verifyFare(
        executionId: executionId.value,
        provider: provider,
        itineraryIdList: List<String>.from(itineraryIdList),
      );

      // Step 4: Hold the booking to get the PNR
      final holdResponse = await _apiService.holdBooking(holdRequest);
      if (holdResponse != null && holdResponse.bookingLocator.isNotEmpty) {
        bookingLocator.value = holdResponse.bookingLocator;
        print(
          '✅ startBooking: PNR=${bookingLocator.value} | status=${holdResponse.status}',
        );

        // Payment options are already in the hold response
        if (holdResponse.paymentOptions.isNotEmpty) {
          paymentOptions.assignAll(holdResponse.paymentOptions);
          print(
            '✅ Payment options from hold: ${holdResponse.paymentOptions.map((o) => '${o.name}(id:${o.id})').toList()}',
          );
        } else {
          // Fallback: try the separate get-payment-options endpoint
          try {
            final options = await _apiService.getPaymentOptions(holdRequest);
            if (options.isNotEmpty) {
              paymentOptions.assignAll(options);
              print('✅ Payment options from separate call: ${options.length}');
            }
          } catch (e) {
            print('⚠️ Could not load payment options (non-fatal): $e');
          }
        }
      } else {
        throw Exception('Hold returned empty PNR. Raw response logged above.');
      }

      // Booking hold succeeded — return true regardless of payment options
      return true;
    } catch (e) {
      errorMessage.value = 'Booking failed: $e';
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> confirmBooking(
    String locator,
    PaymentOption option,
    CardInfo? card,
  ) async {
    try {
      isLoading.value = true;
      final confirmRequest = ConfirmBookingRequest(
        bookingLocator: locator,
        payOption: option,
        cardInfo: card,
      );

      final response = await _apiService.confirmPayment(confirmRequest);
      if (response != null) {
        // Extract traceNumber and txnref from the real response
        final order = response['data']?['order'];
        final traceNumber =
            order?['traceNumber']?.toString() ??
            'TR-${DateTime.now().millisecondsSinceEpoch}';
        final tracking =
            order?['tracking']?.toString() ??
            'TX-${DateTime.now().millisecondsSinceEpoch}';
        final status = order?['status']?.toString() ?? '0001';

        print(
          '✅ confirmBooking: traceNumber=$traceNumber | tracking=$tracking | status=$status',
        );
        await submitPaymentCallback(status, traceNumber, tracking);
        return true;
      }
    } catch (e) {
      errorMessage.value = 'Payment confirmation failed: $e';
      print('❌ confirmBooking error: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> submitPaymentCallback(
    String status,
    String trace,
    String ref,
  ) async {
    try {
      final callbackRequest = PaymentCallbackRequest(
        status: status,
        traceNumber: trace,
        txnref: ref,
      );
      await _apiService.submitPaymentCallback(callbackRequest);
    } catch (e) {
      print('Payment callback error: $e');
    }
  }
}
