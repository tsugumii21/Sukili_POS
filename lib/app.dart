import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'core/services/supabase_service.dart';
import 'shared/providers/theme_provider.dart';
import 'app_router.dart';

class SukliPosApp extends ConsumerStatefulWidget {
  const SukliPosApp({super.key});

  @override
  ConsumerState<SukliPosApp> createState() => _SukliPosAppState();
}

class _SukliPosAppState extends ConsumerState<SukliPosApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle link if app was launched from a cold start via deep link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Handle links while app is already running
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (e) => debugPrint('Deep link error: $e'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');

    // Supabase puts the session tokens in the fragment (#)
    // app_links gives us access_token and refresh_token in the uri
    if (uri.scheme == 'com.suklipos.sukli_pos' && uri.host == 'auth-callback') {
      // Extract tokens from fragment or query params
      final fragment = uri.fragment;
      final params = Uri.splitQueryString(fragment);
      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];

      if (accessToken != null && refreshToken != null) {
        // Set the session in Supabase
        SupabaseService.instance.client.auth.setSession(accessToken);
        // Navigate to admin login to complete sign in
        ref.read(appRouterProvider).go(RouteConstants.adminLogin);
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sukli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
