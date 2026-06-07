import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/book_detail/book_detail_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/reading_list/reading_list_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/settings/settings_screen.dart';

class AppRouter {
  AppRouter(this.authProvider);

  final AuthProvider authProvider;
  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/login';
      }
      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (_, state) => BookDetailScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/reading-list',
        builder: (_, __) => const ReadingListScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (_, __) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
