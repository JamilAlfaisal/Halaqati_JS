import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/models/event.dart'; // Ensure this matches your file path
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/event_api_provider.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';

final eventProvider = AsyncNotifierProvider<EventNotifier, List<Event>?>(EventNotifier.new);

class EventNotifier extends AsyncNotifier<List<Event>?> {

  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  Future<List<Event>?> build() async {
    _offset = 0;
    _hasMore = true;

    return await _fetchEvents(reset: true);
  }

  Future<List<Event>?>
  _fetchEvents({bool reset = false}) async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";
    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      final events = await ref
          .read(eventApiProvider)
          .getEvents(token, classId, offset: _offset, limit: _limit);

      if (reset) {
        _offset = events.length;
        _hasMore = events.length == _limit;
        return events;
      } else {
        _offset += events.length;
        if (events.length < _limit) _hasMore = false;
        return [...?state.value, ...events];
      }
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final isLoadingMore = isLoadingMoreProvider("events");
    if (!_hasMore || ref.read(isLoadingMore)) return;
    ref.read(isLoadingMore.notifier).state = true;
    try {
      final newEvents = await _fetchEvents();
      state = AsyncData(newEvents);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }finally{
      ref.read(isLoadingMore.notifier).state = false;
    }
  }

  /// Deletes an event and refreshes the local state
  Future<void> deleteEvent(String eventId) async {
    final token = ref
        .read(tokenProvider)
        .value;
    if (token == null) throw UnauthorizedException();

    try {
      await ref.read(eventApiProvider).deleteEvent(token, eventId);

      state = AsyncData(state.value?.where((e) => e.id != eventId).toList() ?? []);
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
      rethrow;
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String dueDate,
    required bool confirmation,
  }) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) return;
    state = const AsyncLoading();
    final classId = ref.watch(selectedClassIdProvider)??"0";

    try {
      final success = await ref.read(eventApiProvider).createEvent(
        token: token,
        title: title,
        description: description,
        dueDate: dueDate,
        classId: classId,
        confirmation: confirmation,
      );
      if (success) {
        ref.invalidateSelf();
        await future;
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    try {

      state = AsyncData(state.value!.map((event) {
        if (event.id == id) {
          return event.copyWith(
            title: title,
            description: description,
            dueDate: dueDate,
          );
        }
        return event;
      }).toList());

    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final eventDetailsProvider = AsyncNotifierProvider<EventDetailsNotifier, Event?>(EventDetailsNotifier.new,);

class EventDetailsNotifier extends AsyncNotifier<Event?> {
  @override
  Future<Event?> build() async {
    final eventId = ref.watch(selectedEventIdProvider);
    if (eventId == null) return null;

    final token = ref.watch(tokenProvider).value;
    if (token == null) return null;
    final Event event = await ref.read(eventApiProvider).getEventDetails(token, eventId);
    print("this is the event provider: ${event.title}");
    return event;
  }

  Future<void> updateEventDetails({
    required String title,
    required String description,
    required String dueDate,
    required bool confirmation,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final eventId = ref.read(selectedEventIdProvider);
      final token = ref.read(tokenProvider).value;

      if (eventId == null || token == null) return null;

      try {
        await ref.read(eventApiProvider).updateEvent(
          token: token,
          event: Event(
            id: eventId,
            title: title,
            description: description,
            dueDate: HelperMethods.parseDate(dueDate),
            confirmation: confirmation,
            createdDate: DateTime.now(),
            teacher: Teacher.emptyTeacher(),
            halaqaClass: ClassModel.emptyClass(),
          )
        );
        return await ref.read(eventApiProvider).getEventDetails(token, eventId);
      } catch (e) {
        if (e is UnauthorizedException) {
          print('Authentication failed during event update');
          await AuthHelper.handleLogout(ref);
        }
        rethrow;
      }
    });
  }
}

class SelectedEventIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final selectedEventIdProvider = NotifierProvider<SelectedEventIdNotifier, String?>(
  SelectedEventIdNotifier.new,
);