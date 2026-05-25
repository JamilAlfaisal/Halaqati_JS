import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/grades_api.dart';

/// Provider for the Grades API service
final gradesApiProvider = Provider<GradesApi>((ref) => GradesApi());