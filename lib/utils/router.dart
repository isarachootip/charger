import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/station_details_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/charging_status_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/login_screen.dart';
import '../screens/history_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/station/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return StationDetailsScreen(stationId: id);
      },
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/charging',
      builder: (context, state) => const ChargingStatusScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
