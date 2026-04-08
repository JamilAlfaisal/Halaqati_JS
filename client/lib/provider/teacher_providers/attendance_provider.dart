import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/attendance_api_provider.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';

final attendanceProvider =
AsyncNotifierProvider<AttendanceNotifier, List<Attendance>?>(
  AttendanceNotifier.new,
);

class AttendanceNotifier extends AsyncNotifier<List<Attendance>?> {

  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<Attendance>?> build() async {
    _offset = 0;
    _hasMore = true;
    return await _fetch(reset: true);
  }

  Future<List<Attendance>?> _fetch({bool reset = false}) async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      final data = await ref
          .read(attendanceApiProvider)
          .getAttendances(
        token: token,
        classId: classId,
        offset: _offset,
        limit: _limit,
      );

      if (reset) {
        _offset = data.length;
        _hasMore = data.length == _limit;
        return data;
      } else {
        _offset += data.length;

        if (data.length < _limit) {
          _hasMore = false;
        }

        return [...?state.value, ...data];
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final loadingProvider = isLoadingMoreProvider("attendance");

    if (!_hasMore || ref.read(loadingProvider)) return;

    ref.read(loadingProvider.notifier).state = true;

    try {
      final newData = await _fetch();
      state = AsyncData(newData);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    } finally {
      ref.read(loadingProvider.notifier).state = false;
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
      await ref.read(attendanceApiProvider).takeAttendance(
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

    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;
      final attendanceId = ref.read(selectedAttendanceProvider);

      if (token == null || attendanceId == null) {
        throw UnauthorizedException();
      }

      await ref.read(attendanceApiProvider).updateAttendance(
        token: token,
        attendanceId: attendanceId,
        studentIds: studentIds,
      );

      ref.invalidate(attendanceDetailsProvider);
      ref.invalidateSelf();

    } catch (e, stack) {
      state = AsyncError(e, stack);

      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
    }
  }

  Future<void> deleteAttendance() async {
    state = const AsyncLoading();

    try {
      final token = ref.read(tokenProvider).value;
      final attendanceId = ref.read(selectedAttendanceProvider);

      if (token == null || attendanceId == null) {
        throw UnauthorizedException();
      }

      await ref.read(attendanceApiProvider).deleteAttendance(
        token: token,
        attendanceId: attendanceId,
      );

      ref.invalidate(attendanceDetailsProvider);   // details
      ref.invalidateSelf();

    } catch (e, stack) {
      state = AsyncError(e, stack);

      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
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
    return await ref.read(attendanceApiProvider).getAttendanceDetails(
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