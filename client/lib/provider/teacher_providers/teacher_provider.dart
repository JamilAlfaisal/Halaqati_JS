import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/teacher.dart';

class TeacherNotifier extends Notifier<Teacher?> {

  @override
  Teacher? build() => null;

  void setTeacher(Teacher teacher) {
    state = teacher;
  }

  void clear() {
    state = null;
  }
}

final teacherProvider = NotifierProvider<TeacherNotifier, Teacher?>(() {
  return TeacherNotifier();
});
