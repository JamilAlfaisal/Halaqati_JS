import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/pages_api.dart';


/// Provider for the Pages API service
final pagesApiProvider = Provider<PagesApi>((ref) => PagesApi());