import 'package:flutter/material.dart';

class CabinTravelerSelector extends StatelessWidget {
  final int adults;
  final String cabin;
  final VoidCallback onTap;

  const CabinTravelerSelector({
    super.key,
    required this.adults,
    required this.cabin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              "$adults traveler, $cabin",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
