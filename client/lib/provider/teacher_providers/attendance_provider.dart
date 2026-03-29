import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';

final attendanceProvider =
AsyncNotifierProvider<AttendanceNotifier, List<Attendance>?>(
  AttendanceNotifier.new,
);

class AttendanceNotifier extends AsyncNotifier<List<Attendance>?> {
  @override
  FutureOr<List<Attendance>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      return await ref
          .read(apiServiceProvider)
          .getAttendances(token: token, classId: classId);
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  /// --- HELPER: Get attendance by ID ---
  Attendance? getAttendanceById(String attendanceId) {
    return state.value?.firstWhere(
          (a) => a.id.toString() == attendanceId,
      orElse: () => throw Exception("Attendance not found in list"),
    );
  }

  /// --- REFRESH ---
  Future<void> refreshAttendances() async {
    try {
      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> takeAttendance({
    required List<int> studentIds,
  }) async {
    final token = ref.read(tokenProvider).value;
    final classId = ref.read(selectedClassIdProvider) ?? "0";

    if (token == null) throw UnauthorizedException();

    try {
      await ref.read(apiServiceProvider).takeAttendance(
        token: token,
        classId: classId,
        studentIds: studentIds,
      );

      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> updateAttendance({
    required List<int> studentIds,
  }) async {
    final token = ref.read(tokenProvider).value;
    final attendanceId = ref.read(selectedAttendanceProvider);

    if (token == null || attendanceId == null) {
      throw UnauthorizedException();
    }

    try {
      await ref.read(apiServiceProvider).updateAttendance(
        token: token,
        attendanceId: attendanceId,
        studentIds: studentIds,
      );
      ref.invalidate(attendanceDetailsProvider);
      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

}

final attendanceDetailsProvider =
FutureProvider<Attendance>((ref) async {
  final token = ref.watch(tokenProvider).value;
  final attendanceId = ref.watch(selectedAttendanceProvider);

  if (token == null || attendanceId == null) {
    throw UnauthorizedException();
  }

  try {
    return await ref.read(apiServiceProvider).getAttendanceDetails(
      token: token,
      attendanceId: attendanceId,
    );
  } catch (e) {
    if (e is UnauthorizedException) {
      await AuthHelper.handleLogout(ref);
    }
    rethrow;
  }
});

final selectedAttendanceProvider = StateProvider<String?>((ref) => null);