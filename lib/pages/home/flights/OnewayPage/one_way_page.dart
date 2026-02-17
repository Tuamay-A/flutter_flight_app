import 'package:expedia/pages/home/flights/widgets/one_way_widget.dart';
import 'package:flutter/material.dart';
class OneWayPage extends StatefulWidget {
  const OneWayPage({super.key});

  @override
  State<OneWayPage> createState() => _OneWayPageState();
}

class _OneWayPageState extends State<OneWayPage> {
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