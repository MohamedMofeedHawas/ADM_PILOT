// lib/core/router/app_router.dart  [UPDATED]
// ═══════════════════════════════════════════════════════════════
// go_router — all named routes for check_list_stress
// Added: profile route, export action
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/history/assessment_detail_screen.dart';
import '../../features/arousal/arousal_screen.dart';
import '../../features/profile/profile_screen.dart';

class Routes {
  static const dashboard        = 'dashboard';
  static const imsafe           = 'imsafe';
  static const pave             = 'pave';
  static const decide           = 'decide';
  static const history          = 'history';
  static const assessmentDetail = 'assessment_detail';
  static const arousal          = 'arousal';
  static const profile          = 'profile';
}

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(child: child, location: state.matchedLocation),
      routes: [
        GoRoute(
          path: '/dashboard', name: Routes.dashboard,
          builder: (_, __) => const DashboardScreen(),
        ),
        // Replace these with your existing screen widgets:
        GoRoute(
          path: '/imsafe', name: Routes.imsafe,
          builder: (_, __) => const _PlaceholderScreen(title: 'IMSAFE'),
        ),
        GoRoute(
          path: '/pave', name: Routes.pave,
          builder: (_, __) => const _PlaceholderScreen(title: 'PAVE'),
        ),
        GoRoute(
          path: '/decide', name: Routes.decide,
          builder: (_, __) => const _PlaceholderScreen(title: 'DECIDE'),
        ),
        GoRoute(
          path: '/history', name: Routes.history,
          builder: (_, __) => const HistoryScreen(),
          routes: [
            GoRoute(
              path: ':id', name: Routes.assessmentDetail,
              builder: (_, state) => AssessmentDetailScreen(
                  recordId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/arousal', name: Routes.arousal,
          builder: (_, __) => const ArousalScreen(),
        ),
      ],
    ),
    // Profile is outside shell — no bottom nav
    GoRoute(
      path: '/profile', name: Routes.profile,
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);

// ── App Shell ─────────────────────────────────────────────────
class AppShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  int _idx(String loc) {
    if (loc.startsWith('/imsafe'))  return 1;
    if (loc.startsWith('/pave'))    return 2;
    if (loc.startsWith('/decide'))  return 3;
    if (loc.startsWith('/history')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FloatingActionButton.small(
        heroTag: 'profile_fab',
        onPressed: () => context.pushNamed(Routes.profile),
        backgroundColor: const Color(0xFF0D1520),
        foregroundColor: const Color(0xFF00BCD4),

        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF1A3A2A)),
        ),
        child: const Icon(Icons.person_outline, size: 18),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _idx(location),
      onDestinationSelected: (i) {
        switch (i) {
          case 0: context.goNamed(Routes.dashboard);
          case 1: context.goNamed(Routes.imsafe);
          case 2: context.goNamed(Routes.pave);
          case 3: context.goNamed(Routes.decide);
          case 4: context.goNamed(Routes.history);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard), label: 'Dashboard',


        ),
        NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), label: 'IMSAFE'),
        NavigationDestination(icon: Icon(Icons.flight_outlined),
            selectedIcon: Icon(Icons.flight), label: 'PAVE'),
        NavigationDestination(icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology), label: 'DECIDE'),
        NavigationDestination(icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history), label: 'History',

        ),

      ],
    ),
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0E14),
    appBar: AppBar(
      backgroundColor: const Color(0xFF0D1520),
      title: Text(title, style: GoogleFonts.shareTechMono(
          color: const Color(0xFF00BCD4), letterSpacing: 2)),
    ),
    body: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.build_outlined,
            size: 40, color: Color(0xFF558866)),
        const SizedBox(height: 12),
        Text('Replace with your $title widget',
            style: const TextStyle(
                color: Color(0xFF558866), fontSize: 13)),
        const SizedBox(height: 6),
        const Text('in lib/core/router/app_router.dart',
            style: TextStyle(
                color: Color(0xFF3A5A4A), fontSize: 12)),
      ],
    )),
  );
}
