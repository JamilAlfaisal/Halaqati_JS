import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/services_providers/assignment_api_provider.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final assignmentProvider = AsyncNotifierProvider<AssignmentNotifier, List<Assignment>?>(
    AssignmentNotifier.new
);

class AssignmentNotifier extends AsyncNotifier<List<Assignment>?> {
  @override
  FutureOr<List<Assignment>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    final studentId = ref.watch(selectedStudentIdProvider) ?? "0";

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      return await ref.read(assignmentApiProvider).getAssignmentOneStudentIassignments(token, studentId);
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Assignment? getSelectedAssignment() {
    final selectedId = ref.read(selectedAssignmentProvider).toString();
    return state.value?.firstWhere(
          (a) => a.id.toString() == selectedId,
      orElse: () => throw Exception("Assignment not found in list"),
    );
  }

  Future<void> createAssignment({
    required String title,
    required String description,
    required String dueDate,
    required List<String> studentsIds,
    required List<String> pages,
    required String type,
  }) async {
    final token = ref.read(tokenProvider).value;
    final classId = ref.read(selectedClassIdProvider) ?? "0";
    if (token == null) throw UnauthorizedException();

    try {
      await ref.read(assignmentApiProvider).createAssignment(
        classId: classId,
        token: token,
        title: title,
        description: description,
        dueDate: dueDate,
        studentsIds: studentsIds,
        pages: pages,
        type: type,
      );
      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> updateAssignmentDetails({
    required String title,
    required String description,
    required String type,
    required List<int> pages,
    required String dueDate,
    required List<int> studentsIds,
  }) async {
    final assignmentId = ref.read(selectedAssignmentProvider).toString();
    final token = ref.read(tokenProvider).value;
    if (token == null) throw UnauthorizedException();
    try {
      await ref.read(assignmentApiProvider).updateAssignment(
        token: token,
        id: assignmentId,
        title: title,
        description: description,
        dueDate: dueDate,
        pages: pages,
        type: type,
        studentsIds: studentsIds,
      );

      if (state.hasValue) {
        state = AsyncData(state.value!.map((a) {
          if (a.id.toString() == assignmentId) {
            // Use copyWith to update the local object
            return a.copyWith(
              title: title,
              description: description,
              type: type,
              pages: pages.map((e) => e.toString()).toList(),
              dueDate: DateTime.parse(dueDate),
            );
          }
          return a;
        }).toList());
      }

      // 3. Background sync
      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) throw UnauthorizedException();

    try {
      if (state.hasValue) {
        state = AsyncData(state.value!.where((a) => a.id.toString() != assignmentId).toList());
      }
      await ref.read(assignmentApiProvider).deleteAssignment(token, assignmentId);
    } catch (e) {
      ref.invalidateSelf();
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }
}

final activeAssignmentProvider = Provider<Assignment?>((ref) {
  final assignmentsAsync = ref.watch(assignmentProvider);
  final selectedId = ref.watch(selectedAssignmentProvider).toString();

  return assignmentsAsync.whenData((list) =>
      list?.firstWhere((a) => a.id.toString() == selectedId)
  ).value;
});