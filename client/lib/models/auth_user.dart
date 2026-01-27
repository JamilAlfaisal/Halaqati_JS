import 'package:halqati/models/student.dart';
import 'package:halqati/models/teacher.dart';

sealed class AuthUser {
  const AuthUser();
}

class AuthTeacher extends AuthUser {
  final Teacher teacher;
  AuthTeacher(this.teacher);
}

class AuthStudent extends AuthUser {
  final Student student;
  AuthStudent(this.student);
}