import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());