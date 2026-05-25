import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/grade_model.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/assignment_api_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';


final classAssignmentsProvider = AsyncNotifierProvider<ClassAssignmentsNotifier, List<Assignment>?>(
    ClassAssignmentsNotifier.new
);


class ClassAssignmentsNotifier extends AsyncNotifier<List<Assignment>?> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<Assignment>?> build() async {
    _offset = 0;
    _hasMore = true;
    return await _fetch(reset: true);
  }

  Future<List<Assignment>?> _fetch({bool reset = false}) async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";

    if (tokenAsync.isLoading) return null;
    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      final data = await ref.read(assignmentApiProvider).getTeacherClassAssignments(
        token,
        classId,
        page: (reset) ? 1 : (_offset ~/ _limit) + 1,
        limit: _limit,
      );

      final fetchedCount = data?.length ?? 0;
      if (reset) {
        _offset = fetchedCount;
        _hasMore = fetchedCount == _limit;
        return data;
      } else {
        _offset += fetchedCount;
        if (fetchedCount < _limit) _hasMore = false;
        return [...?state.value, ...?data];
      }
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final loadingProvider = isLoadingMoreProvider("class_assignments");
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
}