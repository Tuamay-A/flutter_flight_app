import 'package:expedia/pages/home/flights/widgets/one_way_widget.dart';
import 'package:flutter/material.dart';

class StaysSearchPage extends StatefulWidget {
  const StaysSearchPage({super.key});

  @override
  State<StaysSearchPage> createState() => _StaysSearchPageState();
}

class _StaysSearchPageState extends State<StaysSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stays")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [OneWayWidget()]),
      ),
    );
  }
}
