import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/student.dart';

class StudentNotifier extends Notifier<Student?> {

  @override
  Student? build() => null;

  void setStudent(Student student) {
    state = student;
  }

  void clear() {
    state = null;
  }
}

final studentProvider = NotifierProvider<StudentNotifier, Student?>(() {
  return StudentNotifier();
});
