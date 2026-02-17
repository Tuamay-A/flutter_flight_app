import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Explore")),
    body: Center(
      child: Text(
        "Explore destinations and interests here.",
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    ),
  );
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          "Inbox",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        bottom: TabBar(
          tabs: const [
            Tab(text: "Notifications"),
            Tab(text: "Messages"),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Theme.of(context).hintColor,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: const TabBarView(
        children: [
          _TabContent(type: TabContentType.notifications),
          _TabContent(type: TabContentType.messages),
        ],
      ),
    ),
  );
}

enum TabContentType { notifications, messages }

class _TabContent extends StatelessWidget {
  final TabContentType type;
  const _TabContent({required this.type});

  @override
  Widget build(BuildContext context) {
    final bool isNotifications = type == TabContentType.notifications;
    // if (type == TabContentType.notifications) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 22),
      children: [
        Icon(
          isNotifications
              ? Icons.notifications_none
              : Icons.chat_bubble_outline,
          size: 84,
          color: Colors.blue,
        ),
        const SizedBox(height: 22),
        Text(
          isNotifications ? "No notifications yet" : "No messages yet",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 19,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          isNotifications
              ? "You'll get alerts about your trips and account here. Ready to book your next trip?"
              : "Hotels and properties can message you here after you book a stay.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 32),
        if (isNotifications)
          Center(
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const ExplorePage()),
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, // Ensure text is white on blue
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text(
                  "Start exploring",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
