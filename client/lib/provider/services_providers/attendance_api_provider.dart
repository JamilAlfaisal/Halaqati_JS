import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/attendance_api.dart';

final attendanceApiProvider = Provider<AttendanceApi>((ref) => AttendanceApi());