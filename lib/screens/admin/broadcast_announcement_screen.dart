import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class BroadcastAnnouncementScreen extends StatefulWidget {
  const BroadcastAnnouncementScreen({super.key});

  @override
  State<BroadcastAnnouncementScreen> createState() =>
      _BroadcastAnnouncementScreenState();
}

class _BroadcastAnnouncementScreenState
    extends State<BroadcastAnnouncementScreen> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _validateAndSend() {
    setState(() => _errorMessage = null);

    if (_titleController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter an announcement title');
      return;
    }

    if (_messageController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter an announcement message');
      return;
    }

    if (_titleController.text.length > 100) {
      setState(() => _errorMessage = 'Title must be less than 100 characters');
      return;
    }

    if (_messageController.text.length > 500) {
      setState(
        () => _errorMessage = 'Message must be less than 500 characters',
      );
      return;
    }

    _sendBroadcast();
  }

  Future<void> _sendBroadcast() async {
    setState(() => _isLoading = true);

    try {
      final notificationProvider = context.read<NotificationProvider>();

      // Send broadcast announcement to all users
      await notificationProvider.broadcastAnnouncement(
        title: _titleController.text,
        message: _messageController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Announcement sent to all users!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear fields
        _titleController.clear();
        _messageController.clear();

        setState(() => _isLoading = false);

        // Navigate back to admin dashboard
        if (mounted) {
          context.go('/admin');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send announcement: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _sendBroadcast,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Announcement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This announcement will be sent to all users as a notification.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Announcement Title',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.announcement,
                    color: colorScheme.primary,
                  ),
                  hintText: 'Enter announcement title',
                  enabled: !_isLoading,
                  counterText: '${_titleController.text.length}/100',
                ),
                maxLength: 100,
                enabled: !_isLoading,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Message
              Text(
                'Announcement Message',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.message, color: colorScheme.primary),
                  hintText: 'Enter announcement message',
                  enabled: !_isLoading,
                  counterText: '${_messageController.text.length}/500',
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 4,
                maxLength: 500,
                enabled: !_isLoading,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 24),
              // Send Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _validateAndSend,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Sending...' : 'Send Announcement',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
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
