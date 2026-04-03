import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/services_providers/juz_api_provider.dart';
import 'package:halqati/provider/services_providers/class_api_provider.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final studentsProvider = AsyncNotifierProvider<StudentsNotifier, List<Student>?>(StudentsNotifier.new);

class StudentsNotifier extends AsyncNotifier<List<Student>?>{
  @override
  FutureOr<List<Student>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider);

    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    print("token class provider build: $token");
    if (token == null  || token.isEmpty) {
      print("No token found, returning empty state to stop loop.");
      return [];
    }
    try{
      print("try to get Students List");
      return await ref.read(classesApiProvider).getStudents(token, classId??"");
    }catch(e){
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> addStudent(String phone) async {
    final token = ref.read(tokenProvider).value;
    final classId = ref.read(selectedClassIdProvider);
    if (token == null || classId == null) {
      throw Exception("Missing token or class ID");
    }

    try {
      final success = await ref.read(classesApiProvider).addStudentToClass(
        token: token,
        classId: classId,
        phone: phone,
      );
      if (success) {
        ref.invalidateSelf();
      }
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> removeStudent(String phone) async {
    final token = ref.read(tokenProvider).value;
    final classId = ref.read(selectedClassIdProvider);

    if (token == null || classId == null) return;

    try {
      print("phone: ${phone}");
      if (state.hasValue) {
        final currentStudents = state.value!;
        final updatedList = currentStudents.where((s) => s.phone != phone).toList();
        state = AsyncData(updatedList);
      }
      await ref.read(classesApiProvider).removeStudentFromClass(
        token: token,
        classId: classId,
        phone: phone,
      );

      ref.invalidateSelf();

    } catch (e) {
      ref.invalidateSelf();
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> updateMemorizedJuz({
    required String studentId,
    required List<String> newJuzList,
  }) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) throw UnauthorizedException();

    try {
      if (state.hasValue) {
        final currentStudents = state.value!;
        state = AsyncData(currentStudents.map((student) {
          if (student.id == studentId) {
            return student.copyWith(memorizedJuz: newJuzList);
          }
          return student;
        }).toList());
      }

      await ref.read(juzApiProvider).updateStudentJuz(
        token: token,
        studentId: studentId,
        juzList: newJuzList,
      );

      if (state.hasValue) {
        final updatedList = state.value!.map((student) {
          if (student.id == studentId) {
            return student.copyWith(memorizedJuz: newJuzList);
          }
          return student;
        }).toList();

        state = AsyncData(updatedList);
      }

      ref.invalidateSelf();
    } catch (e) {
      ref.invalidateSelf();
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

}


class SelectedStudentIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final selectedStudentIdProvider = NotifierProvider<SelectedStudentIdNotifier, String?>(
  SelectedStudentIdNotifier.new,
);