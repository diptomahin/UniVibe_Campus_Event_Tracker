import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/event_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notificationProvider = context.read<NotificationProvider>();

      context.read<EventProvider>().loadEvents();

      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        notificationProvider.loadNotifications(userId);
        notificationProvider.startReminderCheck(userId);

        Future.doWhile(() async {
          if (mounted) {
            await Future.delayed(Duration(seconds: 10));
            if (mounted) {
              await notificationProvider.loadNotifications(userId);
            }
          }
          return mounted;
        });

        print('✅ Notifications initialized for user: $userId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniVibe'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.notifications
                  .where((n) => !n.isRead)
                  .length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.go('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.go('/debug'),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if any
          if (eventProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text('Error loading events:'),
                    const SizedBox(height: 8),
                    Text(
                      eventProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<EventProvider>().loadEvents(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allEvents = eventProvider.allEvents;
          final todayEvents = allEvents.where((e) => e.isToday).toList();
          final tomorrowEvents = allEvents.where((e) => e.isTomorrow).toList();
          final thisWeekEvents = allEvents.where((e) => e.isThisWeek).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todayEvents.isNotEmpty)
                  _buildEventSection(context, 'Today', todayEvents),
                if (tomorrowEvents.isNotEmpty)
                  _buildEventSection(context, 'Tomorrow', tomorrowEvents),
                if (thisWeekEvents.isNotEmpty)
                  _buildEventSection(context, 'This Week', thisWeekEvents),
                if (allEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text('No upcoming events'),
                          const SizedBox(height: 8),
                          Text(
                            '(${allEvents.length} total events loaded)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<EventProvider>().loadEvents(),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Only show FAB for admins
          if (authProvider.currentUser?.userRole == 'admin') {
            return FloatingActionButton(
              onPressed: () => context.go('/create-event'),
              tooltip: 'Create Event',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEventSection(BuildContext context, String title, List events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: List.generate(
              events.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: EventCard(
                  event: events[index],
                  onTap: () {
                    context.go('/events/${events[index].id}');
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
