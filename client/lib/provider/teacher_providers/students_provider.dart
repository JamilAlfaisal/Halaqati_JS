import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/token_notifier.dart';

final studentsProvider = AsyncNotifierProvider<StudentsNotifier, List<Student>?>(StudentsNotifier.new);

class StudentsNotifier extends AsyncNotifier<List<Student>?>{
  @override
  FutureOr<List<Student>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

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
      print("try to get Students List");
      return await ref.read(apiServiceProvider).getStudents(token);
    }catch(e){
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }
}


class SelectedStudentIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final selectedStudentIdProvider = NotifierProvider<SelectedStudentIdNotifier, int?>(
  SelectedStudentIdNotifier.new,
);