import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/event_confirmation_model.dart';
import 'package:halqati/provider/services_providers/event_api_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final eventConfirmationsProvider = FutureProvider.family<List<EventConfirmationModel>, String>((ref, eventId) async {
  final token = ref.read(tokenProvider).value ?? "";
  if (token.isEmpty) {
    return [];
  }
  return ref.read(eventApiProvider).getEventConfirmations(token, eventId);
});
