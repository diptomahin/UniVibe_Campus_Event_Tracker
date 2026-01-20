import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../widgets/user_stat_card.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  late UserService _userService;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, int>? _userStats;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _searchController.addListener(_filterUsers);
    _loadUsers();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error loading users: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _userService.countUsersByRole();
      setState(() => _userStats = stats);
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final email = (user['email'] as String?)?.toLowerCase() ?? '';
        final name = (user['full_name'] as String?)?.toLowerCase() ?? '';
        return email.contains(query) || name.contains(query);
      }).toList();
    });
  }

  Future<void> _changeUserRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Text('Change role from "$currentRole" to "$newRole"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _userService.updateUserRole(userId, newRole);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ User role changed to $newRole')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error changing role: $e')));
        }
      }
    }
  }

  Future<void> _viewUserStats(String userId) async {
    try {
      final stats = await _userService.getUserStats(userId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('User Activity'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow('Going to Events', stats['going'] ?? 0),
                _statRow('Interested Events', stats['interested'] ?? 0),
                _statRow('Created Events', stats['created'] ?? 0),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error loading stats: $e')));
      }
    }
  }

  Widget _statRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Header
          if (_userStats != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  UserStatCard(
                    label: '👥 Total',
                    value: _userStats!['total'].toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  UserStatCard(
                    label: '👑 Admins',
                    value: _userStats!['admin'].toString(),
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  UserStatCard(
                    label: '📚 Students',
                    value: _userStats!['student'].toString(),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by email or name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Users List
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filteredUsers.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'No users found'
                      : 'No users match your search',
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  final userId = user['id'] as String;
                  final email = user['email'] as String? ?? 'No email';
                  final name = user['full_name'] as String? ?? 'No name';
                  final role = user['user_role'] as String? ?? 'student';
                  final joinDate = user['created_at'] as String?;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: const TextStyle(fontSize: 12)),
                          if (joinDate != null)
                            Text(
                              'Joined: ${DateTime.parse(joinDate).toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('View Activity'),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _viewUserStats(userId),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: Text(
                              role == 'admin' ? 'Revoke Admin' : 'Make Admin',
                            ),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _changeUserRole(userId, role),
                              );
                            },
                          ),
                        ],
                      ),
                      isThreeLine: joinDate != null,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
