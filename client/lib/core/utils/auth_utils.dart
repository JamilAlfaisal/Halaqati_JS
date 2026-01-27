// lib/core/utils/auth_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/teacher_providers/profile_provider.dart';
import 'package:halqati/main.dart'; // For navigatorKey

class AuthHelper {
  /// Handles logout and clears all navigation stacks
  static Future<void> handleLogout(dynamic ref) async {
    try {
      final token = ref.read(tokenProvider).value;
      if (token != null) {
        await ref.read(apiServiceProvider).logout(token);
      }
    } catch (e) {
      debugPrint("API Logout failed, but clearing local data anyway: $e");
    } finally {
      await ref.read(tokenProvider.notifier).logout();

      // 2. Clear all routes from navigation stack
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login_screen', // Replace with your login route name
            (route) => false, // This condition removes ALL previous routes
      );

      // 3. Force authProvider to rebuild
      ref.invalidate(authProvider);
    }
  }
}