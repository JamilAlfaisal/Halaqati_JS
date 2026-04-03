import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());