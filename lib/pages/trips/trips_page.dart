import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripsController extends GetxController {
  var trips = [
    {'name': 'vacation', 'saved': false},
    {'name': 'vacation', 'saved': false},
  ].obs;
}

class TripsPage extends StatelessWidget {
  const TripsPage({Key? key}) : super(key: key);

  void _showPlanTripDialog(BuildContext context, TripsController controller) {
    final _formKey = GlobalKey<FormState>();
    String tripName = "";
    String description = "";
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 12),
                      const Text('Plan a new trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Track things you love and plan your whole trip", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Trip name *', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? "Trip name required" : null,
                    onChanged: (val) => tripName = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    maxLength: 100,
                    onChanged: (val) => description = val,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          controller.trips.add({
                            'name': tripName,
                            'description': description,
                            'saved': false
                          });
                          Get.back();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final TripsController controller = Get.find<TripsController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0, // Hide the standard AppBar
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Plan a trip button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text(
                      "Trip Planner",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text("Plan a trip", style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        shape: StadiumBorder(),
                        side: const BorderSide(color: Colors.blue, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => _showPlanTripDialog(context, controller),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text("Saved", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              // Trip cards
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: controller.trips.length,
                  itemBuilder: (ctx, idx) {
                    final trip = controller.trips[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.grey[400],
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            // Use a pattern background matching the image if you have
                            image: AssetImage('assets/pattern.png'),
                            opacity: 0.1
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                trip['name'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.favorite, color: Colors.red, size: 18),
                                  SizedBox(width: 4),
                                  Text("No saves yet", style: TextStyle(color: Colors.white, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: StadiumBorder(),
                                side: BorderSide.none,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              onPressed: () => Get.snackbar("Invite", "Invite feature coming soon"),
                              icon: const Icon(Icons.group_outlined),
                              label: const Text("Invite"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
              ),
              // Find Your Booking Card
              GestureDetector(
                onTap: () => Get.to(() => FindYourBookingPage()),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12)
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Find your booking",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Use your itinerary number to look it up",
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 22, color: Colors.black)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------
// Screens referenced above:
// ------------------------

class FindYourBookingPage extends StatelessWidget {
  FindYourBookingPage({Key? key}) : super(key: key);

  final TextEditingController itineraryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Find your booking"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            const Text(
              "Enter your itinerary number",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your itinerary number was emailed to you.\nAsterisk \"*\" indicates a required field",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: itineraryController,
              decoration: const InputDecoration(
                labelText: "Itinerary number *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {}, // Add forgot logic if you want
              child: const Text("Forgot your itinerary number?"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle itinerary search
              },
              child: const Text("Continue"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {}, // Implement alternate booking logic
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12)
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Find a booking you made using a different email address",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}