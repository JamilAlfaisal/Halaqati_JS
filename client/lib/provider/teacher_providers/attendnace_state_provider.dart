import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/attendance_state.dart';
import 'package:halqati/provider/services_providers/attendance_api_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final attendanceStatsProvider = AsyncNotifierProvider<
    AttendanceStatsNotifier, List<AttendanceStats>?>(
  AttendanceStatsNotifier.new,
);

class AttendanceStatsNotifier extends AsyncNotifier<List<AttendanceStats>?> {
  String? _fromDate;

  /// 🔹 Remove automatic fetching
  @override
  Future<List<AttendanceStats>?> build() async {
    // Initially do nothing, wait for teacher to trigger fetch
    return null;
  }

  /// 🔹 Set the start date and fetch
  Future<void> setStartDateAndFetch(DateTime fromDate) async {
    _fromDate = fromDate.toIso8601String();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await fetch(fromDate: _fromDate);
    });
  }

  /// 🔹 Fetch from API
  Future<List<AttendanceStats>?> fetch({String? fromDate}) async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      return await ref.read(attendanceApiProvider).getAttendanceStats(
        token: token,
        classId: classId,
        fromDate: fromDate,
      );
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  /// 🔄 Optional manual refresh with existing fromDate
  Future<void> refresh() async {
    if (_fromDate == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await fetch(fromDate: _fromDate);
    });
  }
}