import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteConstants.adminHome);
            }
          },
        ),
        title: const Text('Settings'),
      ),
      body: const Center(child: Text('SettingsScreen — Coming soon')),
    );
  }
}
