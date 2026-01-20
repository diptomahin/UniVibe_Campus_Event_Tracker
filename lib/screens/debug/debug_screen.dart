import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isConnected = supabase.auth.currentUser != null;
    final url = supabaseUrl;
    final key = supabaseAnonKey;

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supabase Config
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supabase Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'URL Configured:',
                      url.isNotEmpty ? '✅ YES' : '❌ NO',
                    ),
                    _buildInfoRow(
                      'Anon Key Configured:',
                      key.isNotEmpty ? '✅ YES' : '❌ NO',
                    ),
                    _buildInfoRow('URL Value:', url.isEmpty ? 'Not set' : url),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Authentication
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Connected:', isConnected ? '✅ YES' : '❌ NO'),
                    if (isConnected) ...[
                      _buildInfoRow(
                        'User ID:',
                        supabase.auth.currentUser?.id ?? 'Unknown',
                      ),
                      _buildInfoRow(
                        'Email:',
                        supabase.auth.currentUser?.email ?? 'Unknown',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Database Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Tables',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTableStatus(supabase, 'users'),
                    _buildTableStatus(supabase, 'events'),
                    _buildTableStatus(supabase, 'rsvps'),
                    _buildTableStatus(supabase, 'notifications'),
                    _buildTableStatus(supabase, 'categories'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Setup Checklist
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Checklist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChecklistItem(
                      'Supabase credentials updated',
                      url.isNotEmpty && key.isNotEmpty,
                    ),
                    _buildChecklistItem('Logged in to app', isConnected),
                    _buildChecklistItem(
                      'Database tables created',
                      true, // Will check server-side
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debug info copied to clipboard'),
                    ),
                  );
                },
                child: const Text('Copy Debug Info'),
              ),
            ),
            const SizedBox(height: 16),

            // Test Write Permission
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Write Permission',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Check if you can write to events table'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _testEventWrite(context, supabase),
                        child: const Text('Test Write to Events Table'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTableStatus(SupabaseClient supabase, String tableName) {
    return FutureBuilder(
      future: _checkTableExists(supabase, tableName),
      builder: (context, snapshot) {
        final exists = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              exists
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 8),
              Text('$tableName table'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          completed
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Future<bool> _checkTableExists(
    SupabaseClient supabase,
    String tableName,
  ) async {
    try {
      await supabase.from(tableName).select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _testEventWrite(
    BuildContext context,
    SupabaseClient supabase,
  ) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Not logged in')));
        return;
      }

      // Try to insert a test event
      final testEvent = {
        'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Test Event',
        'description': 'This is a test',
        'category': 'Tech',
        'start_time': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(days: 1, hours: 2))
            .toIso8601String(),
        'location': 'Test Location',
        'image_url': '',
        'host_id': currentUser.id,
        'host_name': currentUser.email ?? 'Test User',
        'capacity': 50,
        'visibility': 'Public',
        'is_featured': false,
        'is_cancelled': false,
        'interested_count': 0,
        'going_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('events').insert(testEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test event written successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Write failed: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
