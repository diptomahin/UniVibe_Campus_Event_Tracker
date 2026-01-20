import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/event_provider.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton(
                onPressed: () => context.go('/create-event'),
                child: const Text('+ New Event'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, _) {
                if (eventProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (eventProvider.allEvents.isEmpty) {
                  return Center(
                    child: Text(
                      'No events found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: eventProvider.allEvents.length,
                  itemBuilder: (context, index) {
                    final event = eventProvider.allEvents[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.formattedStartTime),
                            Text(
                              'Going: ${event.goingCount} | Interested: ${event.interestedCount}',
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                context.go('/edit-event/${event.id}');
                              },
                              child: const Text('Edit'),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                _showDeleteConfirmation(
                                  context,
                                  event.id,
                                  event.title,
                                );
                              },
                              child: const Text('Delete'),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                _toggleFeatured(context, event);
                              },
                              child: Text(
                                event.isFeatured ? 'Unfeature' : 'Feature',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String eventId,
    String eventTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "$eventTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<EventProvider>().deleteEvent(eventId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Event deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleFeatured(BuildContext context, dynamic event) {
    final updatedEvent = event.copyWith(isFeatured: !event.isFeatured);
    context.read<EventProvider>().updateEvent(event.id, updatedEvent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          event.isFeatured ? '✅ Event unfeatured' : '✅ Event featured',
        ),
      ),
    );
  }
}
