import 'package:expedia/pages/home/flights/widgets/one_way_widget.dart';
import 'package:flutter/cupertino.dart';

class RoundtripPage extends StatefulWidget {
  const RoundtripPage({super.key});

  @override
  State<RoundtripPage> createState() => _RoundTripState();
}

class _RoundTripState extends State<RoundtripPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          OneWayWidget(),
        ],
      ),
    );
  }
}
