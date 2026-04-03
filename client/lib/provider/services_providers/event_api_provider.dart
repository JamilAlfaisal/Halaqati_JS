import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/services/event_api.dart';

final eventApiProvider = Provider<EventApi>((ref) => EventApi());