class FlightSearchRequest {
  final List<OriginDestination> originDestinations;
  final Travellers travellers;

  FlightSearchRequest({
    required this.originDestinations,
    required this.travellers,
  });

  Map<String, dynamic> toJson() => {
        'originDestinations': originDestinations.map((e) => e.toJson()).toList(),
        'travellers': travellers.toJson(),
      };
}

class OriginDestination {
  final Location departure;
  final Location arrival;

  OriginDestination({
    required this.departure,
    required this.arrival,
  });

  Map<String, dynamic> toJson() => {
        'departure': departure.toJson(),
        'arrival': arrival.toJson(),
      };
}

class Location {
  final String airportCode;
  final String? date;

  Location({
    required this.airportCode,
    this.date,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'airportCode': airportCode};
    if (date != null) json['date'] = date!;
    return json;
  }
}

class Travellers {
  final int adt;
  final int chd;
  final int inf;

  Travellers({
    this.adt = 1,
    this.chd = 0,
    this.inf = 0,
  });

  Map<String, dynamic> toJson() => {
        'adt': adt,
        'chd': chd,
        'inf': inf,
      };
}
