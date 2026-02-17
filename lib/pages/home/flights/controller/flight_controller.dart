import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../roundtrip/flight_results_page.dart';

class FlightController extends GetxController {
  // Observables (.obs) replace setState
  var fromCity = TextEditingController().obs;
  var toCity = TextEditingController().obs;
  var dateRangeText = "Select dates".obs;
  var travelers = 1.obs;
  var cabinClass = "Economy".obs;
  var addStay = false.obs;

  void swapCities() {
    String temp = fromCity.value.text;
    fromCity.value.text = toCity.value.text;
    toCity.value.text = temp;
  }

  void updateDateRange(DateTimeRange? range) {
    if (range != null) {
      // Mon, Mar 2 style
      String start = DateFormat('EEE, MMM d').format(range.start);
      String end = DateFormat('EEE, MMM d').format(range.end);
      dateRangeText.value = "$start - $end";
    }
  }

  void performSearch() {
    if (fromCity.value.text.isEmpty || toCity.value.text.isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please select cities",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Expedia Style Loading Transition
    Get.dialog(
      Scaffold(
        // backgroundColor: const Color(0xFF003580), // Expedia Navy
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(Icons.flight_takeoff, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Searching for flights...",
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.blue),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate search delay then navigate
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Close loading
      Get.to(() => FlightResultsPage());
    });
  }

  @override
  void onClose() {
    fromCity.value.dispose();
    toCity.value.dispose();
    super.onClose();
  }
}
