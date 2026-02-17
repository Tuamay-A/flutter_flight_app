import 'package:expedia/pages/home/flights/widgets/one_way_widget.dart';
import 'package:flutter/cupertino.dart';

class StaysPage extends StatefulWidget {
  const StaysPage({super.key});

  @override
  State<StaysPage> createState() => _StaysPageState();
}

class _StaysPageState extends State<StaysPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [OneWayWidget()]),
    );
  }
}
