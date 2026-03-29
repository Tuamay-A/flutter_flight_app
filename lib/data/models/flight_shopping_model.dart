class FlightShoppingRequest {
  final List<OriginDestination> originDestinations;
  final Travellers travellers;
  final Preference preference;
  final String? promoCode;
  final CorporateCode? corporateCode;

  FlightShoppingRequest({
    required this.originDestinations,
    required this.travellers,
    required this.preference,
    this.promoCode,
    this.corporateCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'originDestinations': originDestinations.map((v) => v.toJson()).toList(),
      'travellers': travellers.toJson(),
      'preference': preference.toJson(),
    };
    if (promoCode != null) data['promoCode'] = promoCode;
    if (corporateCode != null) data['corporateCode'] = corporateCode!.toJson();
    return data;
  }
}

class OriginDestination {
  final Departure departure;
  final Arrival arrival;

  OriginDestination({required this.departure, required this.arrival});

  Map<String, dynamic> toJson() => {
    'departure': departure.toJson(),
    'arrival': arrival.toJson(),
  };
}

class Departure {
  final String airportCode;
  final String date;

  Departure({required this.airportCode, required this.date});

  Map<String, dynamic> toJson() => {'airportCode': airportCode, 'date': date};
}

class Arrival {
  final String airportCode;

  Arrival({required this.airportCode});

  Map<String, dynamic> toJson() => {'airportCode': airportCode};
}

class Travellers {
  final int adt;
  final int chd;
  final int inf;
  final int ins;
  final int unn;

  Travellers({
    required this.adt,
    this.chd = 0,
    this.inf = 0,
    this.ins = 0,
    this.unn = 0,
  });

  Map<String, dynamic> toJson() => {
    'adt': adt,
    'chd': chd,
    'inf': inf,
    'ins': ins,
    'unn': unn,
  };
}

class Preference {
  final CabinPreferences cabinPreferences;

  Preference({required this.cabinPreferences});

  Map<String, dynamic> toJson() => {
    'cabinPreferences': cabinPreferences.toJson(),
  };
}

class CabinPreferences {
  final CabinType cabinType;

  CabinPreferences({required this.cabinType});

  Map<String, dynamic> toJson() => {'cabinType': cabinType.toJson()};
}

class CabinType {
  final String code;

  CabinType({required this.code});

  Map<String, dynamic> toJson() => {'code': code.toLowerCase()};
}

class CorporateCode {
  final List<String> accountNumber;
  final String airlineCode;

  CorporateCode({required this.accountNumber, required this.airlineCode});

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'airlineCode': airlineCode,
  };
}

// ─── Response Models ───

class FlightShoppingResponse {
  final List<FlightOffer> offers;

  FlightShoppingResponse({required this.offers});

  factory FlightShoppingResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> offersList = [];

    if (json['data'] != null && json['data']['qrFlights'] != null) {
      offersList = json['data']['qrFlights']['offers'] ?? [];
    } else if (json['data'] != null && json['data']['flightOffers'] != null) {
      offersList = json['data']['flightOffers'];
    } else if (json['offers'] != null) {
      offersList = json['offers'];
    }

    return FlightShoppingResponse(
      offers: offersList.map((i) => FlightOffer.fromJson(i)).toList(),
    );
  }
}

class FlightOffer {
  final String id; // offerId
  final String? offerItemId;
  final String? provider;
  final FlightPrice price;
  final String airline;
  final List<FlightItinerary> itineraries;
  // Raw flights list — needed to extract productId for itineraryIdList
  final List<FlightLeg> flights;
  final List<BaggageService> baggageServices;

  FlightOffer({
    required this.id,
    this.offerItemId,
    this.provider,
    required this.price,
    required this.airline,
    required this.itineraries,
    required this.flights,
    this.baggageServices = const [],
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    final flightsList = (json['flights'] as List? ?? [])
        .map((f) => FlightLeg.fromJson(f))
        .toList();

    return FlightOffer(
      id: json['offerId'] ?? json['id'] ?? '',
      offerItemId: json['offerItemId'],
      provider: json['provider'],
      price: FlightPrice.fromJson(json['pricing'] ?? json['price'] ?? {}),
      airline: _extractAirline(json),
      itineraries: _extractItineraries(json),
      flights: flightsList,
      baggageServices: (json['baggageServices'] as List? ?? [])
          .map((b) => BaggageService.fromJson(b))
          .toList(),
    );
  }

  /// itineraryIdList = flights[].productId  (NOT segment ids)
  List<String> get itineraryIdList =>
      flights.map((f) => f.productId).where((id) => id.isNotEmpty).toList();

  static String _extractAirline(Map<String, dynamic> json) {
    try {
      final flights = json['flights'] as List?;
      if (flights != null && flights.isNotEmpty) {
        final segments = flights[0]['segments'] as List?;
        if (segments != null && segments.isNotEmpty) {
          return segments[0]['airlineName'] ?? segments[0]['airlineCode'] ?? '';
        }
      }
    } catch (_) {}
    return json['airline'] ?? '';
  }

  static List<FlightItinerary> _extractItineraries(Map<String, dynamic> json) {
    final flights = json['flights'] as List?;
    if (flights == null) return [];

    return flights.map((f) {
      final segments = (f['segments'] as List? ?? []);
      return FlightItinerary(
        duration: f['duration'] ?? '',
        productId: f['productId'] ?? '',
        originCode: f['originCode'] ?? '',
        destinationCode: f['destinationCode'] ?? '',
        segments: segments.map((s) => FlightSegment.fromJson(s)).toList(),
      );
    }).toList();
  }
}

class FlightLeg {
  final String productId;
  final String duration;
  final String originCode;
  final String destinationCode;

  FlightLeg({
    required this.productId,
    required this.duration,
    required this.originCode,
    required this.destinationCode,
  });

  factory FlightLeg.fromJson(Map<String, dynamic> json) {
    return FlightLeg(
      productId: json['productId'] ?? '',
      duration: json['duration'] ?? '',
      originCode: json['originCode'] ?? '',
      destinationCode: json['destinationCode'] ?? '',
    );
  }
}

class BaggageService {
  final String typeCode;
  final int totalQuantity;
  final String description;

  BaggageService({
    required this.typeCode,
    required this.totalQuantity,
    required this.description,
  });

  factory BaggageService.fromJson(Map<String, dynamic> json) {
    return BaggageService(
      typeCode: json['typeCode'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'typeCode': typeCode,
    'totalQuantity': totalQuantity,
    'description': description,
  };
}

class FlightPrice {
  final String total;
  final String baseFare;
  final String taxes;
  final String currency;

  FlightPrice({
    required this.total,
    required this.baseFare,
    required this.taxes,
    required this.currency,
  });

  factory FlightPrice.fromJson(Map<String, dynamic> json) {
    return FlightPrice(
      total: json['total']?.toString() ?? '0',
      baseFare: json['baseFare']?.toString() ?? json['base']?.toString() ?? '0',
      taxes: json['taxes']?.toString() ?? json['fees']?.toString() ?? '0',
      currency: json['currency'] ?? 'USD',
    );
  }
}

class FlightItinerary {
  final String duration;
  final String productId;
  final String originCode;
  final String destinationCode;
  final List<FlightSegment> segments;

  FlightItinerary({
    required this.duration,
    required this.productId,
    required this.originCode,
    required this.destinationCode,
    required this.segments,
  });

  factory FlightItinerary.fromJson(Map<String, dynamic> json) {
    return FlightItinerary(
      duration: json['duration'] ?? '',
      productId: json['productId'] ?? '',
      originCode: json['originCode'] ?? '',
      destinationCode: json['destinationCode'] ?? '',
      segments: (json['segments'] as List? ?? [])
          .map((i) => FlightSegment.fromJson(i))
          .toList(),
    );
  }
}

class FlightSegment {
  final String id;
  final String number; // flightNumber
  final String carrierCode; // airlineCode
  final String airlineName;
  final String operatingAirlineCode;
  final FlightEndpoint departure;
  final FlightEndpoint arrival;
  final String classOfService;
  final String rbd;

  FlightSegment({
    required this.id,
    required this.number,
    required this.carrierCode,
    this.airlineName = '',
    this.operatingAirlineCode = '',
    required this.departure,
    required this.arrival,
    this.classOfService = '',
    this.rbd = '',
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      id: json['id']?.toString() ?? json['flightNumber']?.toString() ?? '',
      number: json['flightNumber'] ?? json['number'] ?? '',
      carrierCode: json['airlineCode'] ?? json['carrierCode'] ?? '',
      airlineName: json['airlineName'] ?? '',
      operatingAirlineCode:
          json['operatingArlineCode'] ?? json['operatingAirlineCode'] ?? '',
      departure: FlightEndpoint(
        iataCode: json['departureAirport'] ?? json['iataCode'] ?? '',
        at: json['departureDateTime'] ?? '',
        airportName: json['departureAirportName'] ?? '',
      ),
      arrival: FlightEndpoint(
        iataCode: json['arrivalAirport'] ?? '',
        at: json['arrivalDateTime'] ?? '',
        airportName: json['arrivalAirportName'] ?? '',
      ),
      classOfService: json['classOfService'] ?? '',
      rbd: json['rbd'] ?? '',
    );
  }
}

class FlightEndpoint {
  final String iataCode;
  final String at;
  final String airportName;

  FlightEndpoint({
    required this.iataCode,
    required this.at,
    this.airportName = '',
  });

  factory FlightEndpoint.fromJson(Map<String, dynamic> json) {
    return FlightEndpoint(
      iataCode: json['iataCode'] ?? '',
      at: json['at'] ?? '',
      airportName: json['airportName'] ?? '',
    );
  }
}

// ─── Offer Price Models ───

class OfferPriceRequest {
  final String executionId;
  final String provider;
  final List<OfferItem> offerItems;
  final List<String> itineraryIdList;
  final Travellers travellers;
  final List<OriginDestination> originDestinations;

  OfferPriceRequest({
    required this.executionId,
    required this.provider,
    required this.offerItems,
    required this.itineraryIdList,
    required this.travellers,
    required this.originDestinations,
  });

  Map<String, dynamic> toJson() => {
    'executionId': executionId,
    'fareId': executionId,
    'provider': provider,
    'metadata': {
      'country': 'ET',
      'currency': 'USD',
      'locale': 'en-US',
      'traceId': null,
    },
    'offerItems': offerItems.map((e) => e.toJson()).toList(),
    'travellers': travellers.toJson(),
    'originDestinations': originDestinations.map((o) => o.toJson()).toList(),
    'itineraryIdList': itineraryIdList,
  };
}

class OfferItem {
  final String offerId;
  final String offerItemId;
  final String owner; // provider
  final List<dynamic> baggageAllowance;
  final String baseAmount; // baseFare
  final String taxAmount; // taxes
  final String totalAmount;
  final String currency;

  OfferItem({
    required this.offerId,
    required this.offerItemId,
    required this.owner,
    this.baggageAllowance = const [],
    required this.baseAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    'offerId': offerId,
    'offerItemId': offerItemId,
    'owner': owner,
    'baggageAllowance': baggageAllowance,
    'baseAmount': baseAmount,
    'taxAmount': taxAmount,
    'totalAmount': totalAmount,
    'currency': currency,
  };
}
