import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/event_card.dart';
import 'package:go_router/go_router.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Going'),
            Tab(text: 'Interested'),
            Tab(text: 'Created'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(userProvider.goingEvents),
              _buildEventList(userProvider.interestedEvents),
              _buildEventList(userProvider.createdEvents),
              _buildEventList(userProvider.pastEvents),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List events) {
    return events.isEmpty
        ? Center(
            child: Text(
              'No events',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: EventCard(
                event: events[index],
                onTap: () {
                  context.go('/events/${events[index].id}');
                },
              ),
            ),
          );
  }
}
