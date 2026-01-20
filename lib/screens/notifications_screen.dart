import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<NotificationProvider>().loadNotifications(userId);

        // Auto-refresh notifications every 5 seconds
        Future.doWhile(() async {
          if (mounted) {
            await Future.delayed(Duration(seconds: 5));
            if (mounted) {
              await context.read<NotificationProvider>().loadNotifications(
                userId,
              );
            }
          }
          return mounted;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              if (notificationProvider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    final userId = context.read<AuthProvider>().currentUser?.id;
                    if (userId != null) {
                      context.read<NotificationProvider>().markAllAsRead(
                        userId,
                      );
                    }
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text(
                    'Mark All as Read',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, NotificationProvider>(
        builder: (context, authProvider, notificationProvider, _) {
          final userId = authProvider.currentUser?.id;

          if (userId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please log in to see notifications'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                onDismissed: (_) {
                  notificationProvider.deleteNotification(notification.id);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(notification.type),
                      child: _getNotificationIcon(notification.type),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                    onTap: () {
                      if (!notification.isRead) {
                        notificationProvider.markAsRead(notification.id);
                      }
                      // Navigate to event if needed
                      context.go('/events/${notification.eventId}');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.orange;
      case 'announcement':
        return Colors.blue;
      case 'rsvp_update':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return const Icon(Icons.alarm, color: Colors.white);
      case 'announcement':
        return const Icon(Icons.notification_important, color: Colors.white);
      case 'rsvp_update':
        return const Icon(Icons.check_circle, color: Colors.white);
      default:
        return const Icon(Icons.notifications, color: Colors.white);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
