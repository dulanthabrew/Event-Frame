import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/config/supabase_config.dart';
import 'app/router/app_router.dart';
import 'app/services/revenue_cat_service.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize RevenueCat (mobile only)
  await RevenueCatService.initialize();

  runApp(
    const ProviderScope(
      child: EventFrameApp(),
    ),
  );
}

class EventFrameApp extends ConsumerWidget {
  const EventFrameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'EventFrame',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
