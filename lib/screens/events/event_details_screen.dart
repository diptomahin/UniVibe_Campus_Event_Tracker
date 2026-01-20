import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEventDetails(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event link copied!')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<EventProvider, AuthProvider>(
        builder: (context, eventProvider, authProvider, _) {
          final event = eventProvider.selectedEvent;

          if (eventProvider.isLoading || event == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  Image.network(
                    event.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.isCancelled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Cancelled',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.calendar_today,
                        event.formattedStartTime,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, event.location),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.person, event.hostName),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _buildRsvpCounts(event),
                      const SizedBox(height: 24),
                      if (authProvider.isAuthenticated && !event.isCancelled)
                        _buildActionButtons(context, event),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildRsvpCounts(Event event) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                '${event.interestedCount}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Interested', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${event.goingCount}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Going', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Event event) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                try {
                  await context.read<UserProvider>().updateRsvpStatus(
                    authProvider.currentUser!.id,
                    event.id,
                    'interested',
                  );
                  // Wait for database to update
                  await Future.delayed(const Duration(milliseconds: 500));
                  // Reload event details
                  if (mounted) {
                    await context.read<EventProvider>().loadEventDetails(
                      event.id,
                    );
                    _showSuccessDialog('✅ Marked as Interested!');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Interested'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                try {
                  await context.read<UserProvider>().updateRsvpStatus(
                    authProvider.currentUser!.id,
                    event.id,
                    'going',
                  );
                  // Wait for database to update
                  await Future.delayed(const Duration(milliseconds: 500));
                  // Reload event details
                  if (mounted) {
                    await context.read<EventProvider>().loadEventDetails(
                      event.id,
                    );
                    _showSuccessDialog('✅ Marked as Going!');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Going'),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
