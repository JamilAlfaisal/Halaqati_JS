import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/class_model.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/services_providers/class_api_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final studentClassesProvider =
AsyncNotifierProvider<StudentClassesNotifier, List<ClassModel>?>(
  StudentClassesNotifier.new,
);

class StudentClassesNotifier extends AsyncNotifier<List<ClassModel>?> {
  @override
  FutureOr<List<ClassModel>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      return await ref
          .read(classesApiProvider)
          .getStudentClasses(token);
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }
  Future<void> refreshClasses() async {
    try {
      ref.invalidateSelf();
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  ClassModel? getSelectedClass() {
    final selectedId = ref.read(selectedClassIdProvider)?.toString();

    return state.value?.firstWhere(
          (c) => c.id.toString() == selectedId,
      orElse: () => throw Exception("Class not found in list"),
    );
  }

}