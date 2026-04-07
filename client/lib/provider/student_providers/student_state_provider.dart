import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/student_states_model.dart';
import 'package:halqati/provider/services_providers/assignment_api_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final studentStatsProvider =
AsyncNotifierProvider<StudentStatsNotifier, StudentStats?>(
    StudentStatsNotifier.new);

class StudentStatsNotifier extends AsyncNotifier<StudentStats?> {
  @override
  Future<StudentStats?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;

    if (token == null || token.isEmpty) return null;

    try {
      final stats =
      await ref.read(assignmentApiProvider).getStudentStats(token);

      return stats;
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  /// 🔄 Manual refresh
  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;
      if (token == null) return;

      final stats =
      await ref.read(assignmentApiProvider).getStudentStats(token);

      state = AsyncData(stats);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}