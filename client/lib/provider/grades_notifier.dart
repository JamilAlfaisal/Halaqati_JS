import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/cumulative_grade_model.dart';
import 'package:halqati/models/grade_model.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/grades_api_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';

final gradesProvider = AsyncNotifierProvider<GradesNotifier, StudentGradeReportModel?>(GradesNotifier.new);

class GradesNotifier extends AsyncNotifier<StudentGradeReportModel?> {
  int _offset = 0;
  int _limit = 5;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<StudentGradeReportModel?> build() async {
    _offset = 0;
    _hasMore = true;
    return await _fetchGrades(reset: true);
  }

  Future<StudentGradeReportModel?> _fetchGrades({bool reset = false}) async {
    final tokenAsync = ref.watch(tokenProvider);

    final studentId = ref.watch(selectedStudentIdProvider)??"0";
    final classId = ref.watch(selectedClassIdProvider) ?? "";
    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;

    if (token == null || token.isEmpty || studentId.isEmpty || classId.isEmpty) {
      return StudentGradeReportModel.empty();
    }

    try {
      final report = await ref
          .read(gradesApiProvider)
          .getStudentGrades(token: token, studentId: studentId, classId: classId, limit: _limit, offset: _offset);

      if (reset) {
        _offset = report?.history.length ?? 0;
        _hasMore = (report?.history.length ?? 0) == _limit;
        return report;
      } else {
        _offset += report?.history.length ?? 0;

        if ((report?.history.length ?? 0) < _limit) {
          _hasMore = false;
        }

        return new StudentGradeReportModel(
          cumulativeGrade: report.cumulativeGrade,
          dateOfregistration: report.dateOfregistration,
          history: [...(state.value?.history??[]), ...report.history],
          totalWeightPoints: report.totalWeightPoints
        );
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {

    final loadingProvider = isLoadingMoreProvider("grades");

    if (!_hasMore || ref.read(loadingProvider)) return;

    ref.read(loadingProvider.notifier).state = true;
    try {
      final newData = await _fetchGrades();
      state = AsyncData(newData);
    }catch(e, stack){
      state = AsyncError(e, stack);
    }finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteGrade(String gradeId) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) throw UnauthorizedException();

    try {

      await ref.read(gradesApiProvider).deleteGrade(
        token: token,
        gradeId: gradeId,
      );

      ref.invalidateSelf();

      await future;

    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  /// Adds a new grade for the selected student and class
  Future<void> addGrade({
    String? assignmentId,
    required double score,
    required int weight,
    String? description,
  }) async {
    final token = ref.read(tokenProvider).value;
    final studentId = ref.read(selectedStudentIdProvider);
    final classId = ref.read(selectedClassIdProvider);

    if (token == null || studentId == null || classId == null) return;

    try {
      final success = await ref.read(gradesApiProvider).addGrade(
        token: token,
        studentId: studentId,
        classId: classId,
        assignmentId: assignmentId,
        score: score,
        weight: weight,
        description: description,
      );

      if (success) {
        ref.invalidateSelf();
        await future;
      }
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  /// Updates an existing grade
  Future<void> updateGrade({
    required String gradeId,
    required double score,
    required int weight,
    String? description,
    String? assignmentId,
  }) async {
    final token = ref.read(tokenProvider).value;
    final studentId = ref.read(selectedStudentIdProvider);
    final classId = ref.read(selectedClassIdProvider);

    if (token == null || studentId == null || classId == null) return;

    try {

      final updatedModel = GradeModel(
        id: gradeId,
        score: score,
        weight: weight,
        description: description,
        dateTime: DateTime.now(),
        teacher: Teacher.emptyTeacher(),
      );

      await ref.read(gradesApiProvider).updateGrade(
        token: token,
        grade: updatedModel,
        studentId: studentId,
        assignmentId: assignmentId,
        classId: classId,
      );

      ref.invalidateSelf();
      await future;
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

}