import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/interceptors.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/no_internet_banner.dart';

class BookShelfApp extends StatefulWidget {
  const BookShelfApp({super.key});

  @override
  State<BookShelfApp> createState() => _BookShelfAppState();
}

class _BookShelfAppState extends State<BookShelfApp> {
  late final AuthProvider _authProvider;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..bootstrap();
    _appRouter = AppRouter(_authProvider);
    onUnauthorized = () {
      _authProvider.logout();
      _appRouter.router.go('/login');
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadLocal(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'BookShelf',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            routerConfig: _appRouter.router,
            builder: (context, child) =>
                NoInternetBanner(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
