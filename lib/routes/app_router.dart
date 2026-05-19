import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../models/stylist.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/list_stylist_page.dart';
import '../pages/detail_stylist_page.dart';
import '../pages/list_layanan_page.dart';
import '../pages/booking_schedule_page.dart';
import '../pages/checkout_booking_page.dart';
import '../pages/riwayat_page.dart';
import '../pages/profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isAuth = context.read<AuthBloc>().state is AuthAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isAuth && !isLoginRoute) return '/login';
    if (isAuth && isLoginRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/stylists',
      builder: (context, state) => const ListStylistPage(),
    ),
    GoRoute(
      path: '/stylist/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailStylistPage(stylistId: id);
      },
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ListLayananPage(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) {
        final stylist = state.extra as Stylist?;
        return BookingSchedulePage(preSelectedStylist: stylist);
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutBookingPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const RiwayatPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
