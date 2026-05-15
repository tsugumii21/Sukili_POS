import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme_mode';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, state == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
