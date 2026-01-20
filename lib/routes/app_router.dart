import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/events/event_details_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/my_events_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/broadcast_announcement_screen.dart';
import '../screens/debug/debug_screen.dart';
import '../screens/notifications_screen.dart';
import '../providers/auth_provider.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/events/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return EventDetailsScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/create-event',
      builder: (context, state) => const CreateEventScreen(),
    ),
    GoRoute(
      path: '/edit-event/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return CreateEventScreen(eventId: eventId);
      },
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/my-events',
      builder: (context, state) => const MyEventsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/broadcast-announcement',
      builder: (context, state) => const BroadcastAnnouncementScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/debug',
      builder: (context, state) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Only show debug screen to admins
            if (authProvider.currentUser?.userRole == 'admin') {
              return const DebugScreen();
            }
            // Non-admins go to home
            return const HomeScreen();
          },
        );
      },
    ),
  ],
);
