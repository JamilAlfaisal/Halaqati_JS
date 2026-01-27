import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/auth_user.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/teacher_providers/teacher_provider.dart';
import 'package:halqati/provider/teacher_providers/student_provider.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
// lib/providers/auth_provider.dart

final studentDashboard = AsyncNotifierProvider<AuthNotifier, Student?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<Student?> {
  @override
  Future<Student?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    // print("profile provider token value $token");
    if (token == null || token.isEmpty) return null;

    try {
      return await ref.read(apiServiceProvider).getStudentDashboard(token);

    } catch (e) {
      if (e is UnauthorizedException) {
        print('Clearing token due to auth/API error');
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }
}

// if (userData['role'] == 'teacher'){
// final Teacher teacher = Teacher.fromJson(userData['user']);
// ref.read(teacherProvider.notifier).setTeacher(teacher);
// Navigator.of(context).pushNamed("/home_app_bar");
// }else{
// final Student student = Student.fromJson(userData['user']);
// ref.read(studentProvider.notifier).setStudent(student);
// Navigator.of(context).pushNamed("/dashboard_app_bar");
// }