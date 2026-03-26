import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final assignmentProvider = AsyncNotifierProvider<AssignmentNotifier, List<Assignment>?>(AssignmentNotifier.new);

class AssignmentNotifier extends AsyncNotifier<List<Assignment>?>{
  @override
  FutureOr<List<Assignment>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    final studentId = ref.watch(selectedStudentIdProvider)??"0";

    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    print("token class provider build: $token");
    if (token == null  || token.isEmpty) {
      // throw UnauthorizedException();
      print("No token found, returning empty state to stop loop.");
      return [];
    }
    try{
      print("try to get assignment List");
      final List<Assignment> assignments = await ref.read(apiServiceProvider).getAssignmentOneStudentIassignments(token, studentId)??[];
      print(assignments);
      return assignments;
    }catch(e){
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
    return [];
  }
  Future<void> createAssignment (
    {
      required String title,
      required String description,
      required String dueDate,
      required List<String> studentsIds,
      required List<String> pages,
      required String type,
    }) async {
    final tokenAsync = ref.read(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider)??"0";

    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    if (token == null) {
      throw UnauthorizedException();
    }

    try{
      await ref.read(apiServiceProvider)
          .createAssignment(
            classId: classId,
            token: token,
            title: title,
            description: description,
            dueDate: dueDate,
            studentsIds: studentsIds,
            pages:pages,
            type: type,
          );
      ref.invalidateSelf();
    } catch(e){
      //e is ApiException
      if (e is UnauthorizedException) {
        print('Clearing token due to auth/API error');
        await AuthHelper.handleLogout(ref);
        // ref.invalidate(authProvider);
      }
      rethrow;
    }
  }

  Future<void> deleteAssignment() async {
    final token = ref.read(tokenProvider).value;
    final assignmentId = ref.watch(selectedAssignmentProvider)??"";
    if (token == null) throw UnauthorizedException();

    try {
      if (state.hasValue) {
        final currentAssignments = state.value ?? [];
        final updatedList = currentAssignments
            .where((assignment) => assignment.id.toString() != assignmentId.toString())
            .toList();
        state = AsyncData(updatedList);
      }
      await ref.read(apiServiceProvider).deleteAssignment(token, assignmentId.toString());
    } catch (e) {
      ref.invalidateSelf();
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }
}
