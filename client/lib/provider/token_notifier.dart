import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/teacher_providers/profile_provider.dart';
import 'package:halqati/storage/token_storage.dart';
import 'dart:async';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    // 1. Initial load: read the token when the app starts
    final storage = ref.read(tokenStorageProvider);
    return await storage.readToken();
  }

  Future<void> login(String token) async {
    // Set state to loading while writing to disk
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final storage = ref.read(tokenStorageProvider);
      await storage.saveToken(token);
      // await storage.saveRefreshToken(refreshToken);
      return token;
    });

    if (state.hasError) {
      print("error at notifier login");
    }
  }

  Future<void> logout() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      await storage.deleteToken();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      state = const AsyncData(null);
    }
  }
}

// 3. Define the global provider
final tokenProvider = AsyncNotifierProvider<TokenNotifier, String?>(() {
  return TokenNotifier();
});
