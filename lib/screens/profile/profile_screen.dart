import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProfileData();
  }

  void _loadProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<UserProvider>().loadUserEvents(
          authProvider.currentUser!.id,
        );
      }
    });
  }

  void _refreshProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        // Refresh user data from database
        authProvider.refreshCurrentUser();
        // Reload user events
        context.read<UserProvider>().loadUserEvents(
          authProvider.currentUser!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.currentUser == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          return user == null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Large icon
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          'Sign in to Your Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Description
                        Text(
                          'Access your profile, saved events, and personalized recommendations',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => context.go('/signup'),
                            child: Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Guest login option
                        TextButton(
                          onPressed: () async {
                            await authProvider.loginAsGuest();
                            if (context.mounted) {
                              context.go('/home');
                            }
                          },
                          child: Text(
                            'Continue as Guest',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                user.fullName?.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.fullName ?? 'User',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                user.bio!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: colorScheme.primary,
                                ),
                                onPressed: () => context.go('/edit-profile'),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (user.userRole == 'admin')
                              _buildProfileOption(
                                Icons.admin_panel_settings,
                                'Admin Dashboard',
                                () => context.go('/admin'),
                              ),
                            _buildProfileOption(
                              Icons.check_circle,
                              'Going Events',
                              () => context.go('/my-events'),
                            ),
                            _buildProfileOption(
                              Icons.bookmark,
                              'Saved Events',
                              () => context.go('/my-events'),
                            ),
                            _buildProfileOption(
                              Icons.event,
                              'Created Events',
                              () => context.go('/my-events'),
                            ),
                            _buildProfileOption(
                              Icons.history,
                              'Past Events',
                              () => context.go('/my-events'),
                            ),
                            const Divider(height: 32),
                            _buildProfileOption(
                              Icons.logout,
                              'Logout',
                              () => authProvider.logout(),
                            ),
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

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[700],
      ),
      onTap: onTap,
    );
  }
}
