import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/assignment_api.dart';

final assignmentApiProvider = Provider<AssignmentApi>((ref) => AssignmentApi());