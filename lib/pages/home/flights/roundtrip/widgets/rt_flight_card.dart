import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/round_trip_models.dart';

class RtFlightCard extends StatelessWidget {
  final RoundTripFlight flight;
  final VoidCallback onSelect;
  final VoidCallback? onFlightDetails;

  const RtFlightCard({
    super.key,
    required this.flight,
    required this.onSelect,
    this.onFlightDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final cardColor = isDark ? const Color(0xFF151A24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3141) : Colors.grey.shade200;
    final textColor = colors.onSurface;
    final mutedColor = colors.onSurface.withValues(alpha: 0.55);
    final accentColor = isDark
        ? const Color(0xFF7FB5FF)
        : const Color(0xFF1565C0);

    final priceText = NumberFormat.simpleCurrency(
      name: 'USD',
      decimalDigits: 0,
    ).format(flight.price);

    final fromName = _airportFullName(flight.fromCity, flight.fromCode);
    final toName = _airportFullName(flight.toCity, flight.toCode);
    final routeText = '$fromName - $toName';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable area
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: icon + times + arrow + price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAirlineIcon(context),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                flight.departTime,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: false,
                              ),
                              const SizedBox(width: 6),
                              _buildArrow(isDark),
                              const SizedBox(width: 6),
                              Text(
                                flight.arriveTime,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              priceText,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'per traveler',
                              style: TextStyle(color: mutedColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: full route names from API
                    Text(
                      routeText,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Row 3: airline name
                    Text(
                      flight.airline.toUpperCase(),
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Row 4: duration · stops
                    Text(
                      '${_formatDuration(flight.duration)} · ${flight.stops}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Flight details — outside the tap
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onFlightDetails ?? () {},
                child: Text(
                  'Flight details',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirlineIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2340) : const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          flight.airline.isNotEmpty ? flight.airline[0].toUpperCase() : '?',
          style: TextStyle(
            color: isDark ? const Color(0xFF7FB5FF) : const Color(0xFF1565C0),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(bool isDark) {
    final color = isDark ? Colors.white38 : Colors.grey.shade400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        Container(width: 24, height: 1.5, color: color),
        Icon(Icons.arrow_forward, size: 12, color: color),
      ],
    );
  }

  String _formatDuration(String duration) {
    if (duration.startsWith('PT')) {
      return duration
          .replaceAll('PT', '')
          .replaceAll('H', 'h ')
          .replaceAll('M', 'm')
          .trim();
    }
    return duration;
  }

  /// fromCity already contains "Airport Name (CODE)" from API
  String _airportFullName(String cityField, String code) {
    // If already formatted (contains parentheses), return as-is
    if (cityField.contains('(')) return cityField;
    return '$cityField ($code)';
  }
}
