// ignore_for_file: unused_element, prefer_final_fields, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../../data/models/flight_shopping_model.dart';
import '../../controllers/flight_controller.dart';
import '../../widgets/flight_selection_widgets.dart';
import '../models/round_trip_models.dart';
import '../widgets/rt_flight_card.dart';
import 'rt_select_fare_page.dart';

class RtDepartingFlightsPage extends StatefulWidget {
  final RoundTripSearchCriteria criteria;
  const RtDepartingFlightsPage({super.key, required this.criteria});

  @override
  State<RtDepartingFlightsPage> createState() => _RtDepartingFlightsPageState();
}

class _RtDepartingFlightsPageState extends State<RtDepartingFlightsPage> {
  late DateTime _selectedDate;

  FlightSortOption _sortOption = FlightSortOption.recommended;
  String _stopFilter = 'Any';
  Set<String> _airlineFilter = {};

  static const int _dateRadius = 10;
  List<DateTime> _dateList = [];
  PageController? _datePageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.criteria.departDate;
    _buildDateList();
    final initialPage = _dateList.indexWhere(
      (d) => _isSameDay(d, _selectedDate),
    );
    _datePageController = PageController(
      viewportFraction: 0.33,
      initialPage: initialPage < 0 ? _dateRadius : initialPage,
    );
  }

  @override
  void dispose() {
    _datePageController?.dispose();
    super.dispose();
  }

  void _buildDateList() {
    final base = widget.criteria.departDate;
    _dateList = List.generate(
      _dateRadius * 2 + 1,
      (i) => base.add(Duration(days: i - _dateRadius)),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _shiftDate(int delta) {
    final idx = _dateList.indexWhere((d) => _isSameDay(d, _selectedDate));
    final newIdx = (idx + delta).clamp(0, _dateList.length - 1);
    setState(() => _selectedDate = _dateList[newIdx]);
    _datePageController?.animateToPage(
      newIdx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _searchForDate(DateTime date) {
    setState(() => _selectedDate = date);
    final controller = Get.find<FlightController>();
    final last = controller.lastSearchRequest.value;
    if (last != null && last.originDestinations.length >= 2) {
      final newRequest = FlightShoppingRequest(
        originDestinations: [
          OriginDestination(
            departure: Departure(
              airportCode: last.originDestinations[0].departure.airportCode,
              date: DateFormat('yyyy-MM-dd').format(date),
            ),
            arrival: Arrival(
              airportCode: last.originDestinations[0].arrival.airportCode,
            ),
          ),
          OriginDestination(
            departure: Departure(
              airportCode: last.originDestinations[1].departure.airportCode,
              date: last.originDestinations[1].departure.date,
            ),
            arrival: Arrival(
              airportCode: last.originDestinations[1].arrival.airportCode,
            ),
          ),
        ],
        travellers: last.travellers,
        preference: last.preference,
        promoCode: last.promoCode,
        corporateCode: last.corporateCode,
      );
      controller.flightOffers.clear();
      controller.searchFlights(newRequest);
    }
    final idx = _dateList.indexWhere((d) => _isSameDay(d, date));
    if (idx >= 0) {
      _datePageController?.animateToPage(
        idx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String get _fromCode {
    final match = RegExp(r'\((\w+)').firstMatch(widget.criteria.from);
    return match?.group(1) ?? widget.criteria.from.split(' ').first;
  }

  String get _toCode {
    final match = RegExp(r'\((\w+)').firstMatch(widget.criteria.to);
    return match?.group(1) ?? widget.criteria.to.split(' ').first;
  }

  String get _fromCity => widget.criteria.from.split(' (').first;
  String get _toCity => widget.criteria.to.split(' (').first;

  int _parseDurationMinutes(String d) {
    final hMatch = RegExp(r'(\d+)h').firstMatch(d);
    final mMatch = RegExp(r'(\d+)m').firstMatch(d);
    return (int.tryParse(hMatch?.group(1) ?? '0') ?? 0) * 60 +
        (int.tryParse(mMatch?.group(1) ?? '0') ?? 0);
  }

  String _toAmPm(String raw) {
    try {
      final t = raw.contains('T') ? raw.split('T').last.substring(0, 5) : raw;
      final parts = t.split(':');
      if (parts.length < 2) return raw;
      int h = int.parse(parts[0]);
      final int m = int.parse(parts[1]);
      final String p = h >= 12 ? 'PM' : 'AM';
      if (h == 0) {
        h = 12;
      } else if (h > 12)
        h -= 12;
      return '$h:${m.toString().padLeft(2, '0')} $p';
    } catch (_) {
      return raw;
    }
  }

  RoundTripFlight _mapOfferToFlight(FlightOffer offer) {
    if (offer.itineraries.isEmpty) {
      return RoundTripFlight(
        id: offer.id,
        airline: offer.airline,
        flightNumber: 'N/A',
        fromCity: widget.criteria.from,
        toCity: widget.criteria.to,
        date: _selectedDate,
        departTime: '12:00 AM',
        arriveTime: '12:00 AM',
        duration: 'N/A',
        stops: 'N/A',
        price: double.tryParse(offer.price.total) ?? 0,
        cabin: widget.criteria.cabinClass,
      );
    }
    final itinerary = offer.itineraries.first;
    final firstSegment = itinerary.segments.first;
    final lastSegment = itinerary.segments.last;
    return RoundTripFlight(
      id: offer.id,
      airline: offer.airline.isNotEmpty
          ? offer.airline
          : firstSegment.carrierCode,
      flightNumber: firstSegment.number,
      fromCity:
          '${firstSegment.departure.airportName.isNotEmpty ? firstSegment.departure.airportName : itinerary.originCode} (${firstSegment.departure.iataCode})',
      toCity:
          '${lastSegment.arrival.airportName.isNotEmpty ? lastSegment.arrival.airportName : itinerary.destinationCode} (${lastSegment.arrival.iataCode})',
      date: _selectedDate,
      departTime: _toAmPm(firstSegment.departure.at),
      arriveTime: _toAmPm(lastSegment.arrival.at),
      duration: itinerary.duration,
      stops: itinerary.segments.length > 1
          ? '${itinerary.segments.length - 1} stop${itinerary.segments.length > 2 ? 's' : ''}'
          : 'Nonstop',
      price: double.tryParse(offer.price.total) ?? 0,
      cabin: widget.criteria.cabinClass,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FlightController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final pageBackground = isDark ? const Color(0xFF0B0F1A) : colors.surface;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            FlightSearchPill(
              routeTitle: '$_fromCode \u21c4 $_toCode',
              dateAndTravelerInfo:
                  '${DateFormat('MMM d').format(_selectedDate)} - ${DateFormat('MMM d').format(widget.criteria.returnDate)}  \u00b7  ${widget.criteria.travelers} traveler${widget.criteria.travelers > 1 ? 's' : ''}',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                if (isLoading) {
                  return Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 3),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          color: const Color(0xFF1565C0),
                          minHeight: 3,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  );
                }
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.flightOffers.isEmpty) {
                  return Center(child: Text(controller.errorMessage.value));
                }
                if (controller.flightOffers.isEmpty) {
                  return const FlightEmptyState();
                }
                return Column(
                  children: [
                    _buildDateScroller(context),
                    Expanded(child: _buildFlightList(context, controller)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        return FlightSortFilterFab(
          hasActiveFilters:
              _sortOption != FlightSortOption.recommended ||
              _stopFilter != 'Any' ||
              _airlineFilter.isNotEmpty,
          onTap: _showSortFilterSheet,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDateScroller(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final borderColor = isDark ? const Color(0xFF2A3141) : Colors.grey.shade200;
    final accentColor = isDark
        ? const Color(0xFF7FB5FF)
        : const Color(0xFF1565C0);
    final bgColor = isDark ? const Color(0xFF151A24) : Colors.white;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _shiftDate(-1),
            child: Container(
              width: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _datePageController,
              itemCount: _dateList.length,
              itemBuilder: (context, idx) {
                final date = _dateList[idx];
                final isSelected = _isSameDay(date, _selectedDate);
                final label =
                    '${DateFormat('MMM d').format(date)} - ${DateFormat('MMM d').format(widget.criteria.returnDate)}';
                return GestureDetector(
                  onTap: () => _searchForDate(date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.1)
                          : bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? accentColor : borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? accentColor : colors.onSurface,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Search',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => _shiftDate(1),
            child: Container(
              width: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightList(BuildContext context, FlightController controller) {
    List<FlightOffer> filteredOffers = controller.flightOffers.where((offer) {
      final flight = _mapOfferToFlight(offer);
      if (_stopFilter == 'Nonstop' && flight.stops != 'Nonstop') return false;
      if (_stopFilter == '1 stop or fewer' &&
          !flight.stops.contains('1 stop') &&
          flight.stops != 'Nonstop') {
        return false;
      }
      if (_airlineFilter.isNotEmpty &&
          !_airlineFilter.contains(flight.airline)) {
        return false;
      }
      return true;
    }).toList();

    if (_sortOption == FlightSortOption.priceLow) {
      filteredOffers.sort(
        (a, b) =>
            double.parse(a.price.total).compareTo(double.parse(b.price.total)),
      );
    } else if (_sortOption == FlightSortOption.priceHigh) {
      filteredOffers.sort(
        (a, b) =>
            double.parse(b.price.total).compareTo(double.parse(a.price.total)),
      );
    } else if (_sortOption == FlightSortOption.durationShort) {
      filteredOffers.sort(
        (a, b) => _parseDurationMinutes(
          _mapOfferToFlight(a).duration,
        ).compareTo(_parseDurationMinutes(_mapOfferToFlight(b).duration)),
      );
    } else if (_sortOption == FlightSortOption.departEarly) {
      filteredOffers.sort(
        (a, b) => _mapOfferToFlight(
          a,
        ).departTime.compareTo(_mapOfferToFlight(b).departTime),
      );
    } else if (_sortOption == FlightSortOption.departLate) {
      filteredOffers.sort(
        (a, b) => _mapOfferToFlight(
          b,
        ).departTime.compareTo(_mapOfferToFlight(a).departTime),
      );
    }

    if (filteredOffers.isEmpty) {
      return const Center(child: Text('No flights match your filters.'));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        const FlightWatchPricesCard(),
        const FlightDisclaimer(),
        const FlightSectionHeader(title: 'Select a departing flight'),
        ...filteredOffers.map((offer) {
          final flight = _mapOfferToFlight(offer);
          return RtFlightCard(
            flight: flight,
            onSelect: () => _selectDepartureFlight(flight),
            onFlightDetails: () => _showFlightDetails(context, flight, offer),
          );
        }),
      ],
    );
  }

  void _showFlightDetails(
    BuildContext context,
    RoundTripFlight flight,
    FlightOffer offer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final bgColor = isDark ? const Color(0xFF0B0F1A) : Colors.white;
    final cardColor = isDark
        ? const Color(0xFF151A24)
        : const Color(0xFFF5F7FA);
    final accentColor = isDark
        ? const Color(0xFF7FB5FF)
        : const Color(0xFF1565C0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (context, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(Icons.close, size: 18, color: colors.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Flight details',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...offer.itineraries.asMap().entries.map((entry) {
              final idx = entry.key;
              final itinerary = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (offer.itineraries.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        idx == 0 ? 'Departing' : 'Returning',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ...itinerary.segments.map(
                    (seg) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    seg.carrierCode.isNotEmpty
                                        ? seg.carrierCode[0]
                                        : '?',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${seg.airlineName.isNotEmpty ? seg.airlineName : seg.carrierCode} ${seg.number}',
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _stopRow(
                            context,
                            seg.departure.iataCode,
                            seg.departure.airportName.isNotEmpty
                                ? seg.departure.airportName
                                : seg.departure.iataCode,
                            _fmtTime(seg.departure.at),
                            _fmtDate(seg.departure.at),
                            accentColor,
                            colors,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: accentColor,
                                  margin: const EdgeInsets.only(left: 11),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Travel time: ${itinerary.duration.replaceAll('PT', '').replaceAll('H', 'h ').replaceAll('M', 'm')}',
                                  style: TextStyle(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _stopRow(
                            context,
                            seg.arrival.iataCode,
                            seg.arrival.airportName.isNotEmpty
                                ? seg.arrival.airportName
                                : seg.arrival.iataCode,
                            _fmtTime(seg.arrival.at),
                            _fmtDate(seg.arrival.at),
                            accentColor,
                            colors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            _infoRow(context, 'Cabin', flight.cabin, colors),
            _infoRow(context, 'Duration', flight.duration, colors),
            _infoRow(context, 'Stops', flight.stops, colors),
            if (offer.baggageServices.isNotEmpty)
              _infoRow(
                context,
                'Baggage',
                offer.baggageServices.map((b) => b.description).join(', '),
                colors,
              ),
          ],
        ),
      ),
    );
  }

  Widget _stopRow(
    BuildContext context,
    String code,
    String name,
    String time,
    String date,
    Color accent,
    ColorScheme colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$name ($code)',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (date.isNotEmpty)
              Text(
                date,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    ColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(String dt) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(dt));
    } catch (_) {
      return _toAmPm(dt);
    }
  }

  String _fmtDate(String dt) {
    try {
      return DateFormat('EEE, MMM d').format(DateTime.parse(dt));
    } catch (_) {
      return '';
    }
  }

  void _showSortFilterSheet() {
    final controller = Get.find<FlightController>();
    showFlightSortFilterSheet(
      context: context,
      currentSort: _sortOption,
      currentStopFilter: _stopFilter,
      currentAirlineFilter: _airlineFilter,
      availableAirlines:
          controller.flightOffers.map((f) => f.airline).toSet().toList()
            ..sort(),
      onApply: (s, st, a) => setState(() {
        _sortOption = s;
        _stopFilter = st;
        _airlineFilter = a;
      }),
    );
  }

  Future<void> _selectDepartureFlight(RoundTripFlight depFlight) async {
    final controller = Get.find<FlightController>();
    final offer = controller.flightOffers.firstWhere(
      (o) => o.id == depFlight.id,
    );

    RoundTripFlight returnFlight;
    if (offer.itineraries.length >= 2) {
      final retItinerary = offer.itineraries[1];
      final firstSeg = retItinerary.segments.first;
      final lastSeg = retItinerary.segments.last;
      returnFlight = RoundTripFlight(
        id: offer.id,
        airline: depFlight.airline,
        flightNumber: firstSeg.number,
        fromCity: widget.criteria.to,
        toCity: widget.criteria.from,
        date: widget.criteria.returnDate,
        departTime: _toAmPm(firstSeg.departure.at),
        arriveTime: _toAmPm(lastSeg.arrival.at),
        duration: retItinerary.duration,
        stops: retItinerary.segments.length > 1
            ? '${retItinerary.segments.length - 1} stop${retItinerary.segments.length > 2 ? 's' : ''}'
            : 'Nonstop',
        price: double.tryParse(offer.price.total) ?? depFlight.price,
        cabin: widget.criteria.cabinClass,
      );
    } else {
      returnFlight = RoundTripFlight(
        id: depFlight.id,
        airline: depFlight.airline,
        flightNumber: depFlight.flightNumber,
        fromCity: widget.criteria.to,
        toCity: widget.criteria.from,
        date: widget.criteria.returnDate,
        departTime: depFlight.departTime,
        arriveTime: depFlight.arriveTime,
        duration: depFlight.duration,
        stops: depFlight.stops,
        price: double.tryParse(offer.price.total) ?? depFlight.price,
        cabin: widget.criteria.cabinClass,
      );
    }

    await Get.showOverlay(
      asyncFunction: () => controller.selectOffer(offer),
      loadingWidget: const SizedBox.shrink(),
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RtSelectFarePage(
          criteria: widget.criteria,
          departureFlight: depFlight,
          returnFlight: returnFlight,
        ),
      ),
    );
  }
}
