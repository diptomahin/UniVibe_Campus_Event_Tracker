import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'tabs/index.dart';
import 'widgets/index.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser?.userRole != 'admin') {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Overview
            _buildStatsOverview(),
            const SizedBox(height: 24),
            // Tabs
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.event), text: 'Events'),
                      Tab(icon: Icon(Icons.people), text: 'Users'),
                      Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                      Tab(icon: Icon(Icons.settings), text: 'Settings'),
                    ],
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      children: const [
                        EventsTab(),
                        UsersTab(),
                        AnalyticsTab(),
                        SettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final totalEvents = eventProvider.allEvents.length;
        final upcomingEvents = eventProvider.allEvents
            .where((e) => e.isUpcoming && !e.isCancelled)
            .length;
        final totalRsvps = eventProvider.allEvents.fold<int>(
          0,
          (sum, e) => sum + e.goingCount + e.interestedCount,
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              StatCard(
                title: 'Total Events',
                value: totalEvents.toString(),
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Upcoming',
                value: upcomingEvents.toString(),
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              StatCard(
                title: 'Total RSVPs',
                value: totalRsvps.toString(),
                color: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }
}
