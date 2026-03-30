import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/models/event.dart'; // Ensure this matches your file path
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';

final eventProvider = AsyncNotifierProvider<EventNotifier, List<Event>?>(EventNotifier.new);

class EventNotifier extends AsyncNotifier<List<Event>?> {
  @override
  FutureOr<List<Event>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);
    final classId = ref.watch(selectedClassIdProvider) ?? "0";

    if (tokenAsync.isLoading) {
      return null;
    }

    final token = tokenAsync.value;

    if (token == null || token.isEmpty) {
      print("No token found for EventProvider, returning empty list.");
      return [];
    }

    try {
      final List<Event> events = await ref.read(apiServiceProvider).getEvents(
          token, classId);
      return events;
    } catch (e) {
      print("catched error in the event provider: ${e}");
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  /// Deletes an event and refreshes the local state
  Future<void> deleteEvent(String eventId) async {
    final token = ref
        .read(tokenProvider)
        .value;
    if (token == null) throw UnauthorizedException();

    try {
      await ref.read(apiServiceProvider).deleteEvent(token, eventId);

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
  }) async {
    final token = ref.read(tokenProvider).value;
    if (token == null) return;
    state = const AsyncLoading();
    final classId = ref.watch(selectedClassIdProvider)??"0";

    try {
      final success = await ref.read(apiServiceProvider).createEvent(
        token: token,
        title: title,
        description: description,
        dueDate: dueDate,
        classId: classId,
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
    final Event event = await ref.read(apiServiceProvider).getEventDetails(token, eventId);
    print("this is the event provider: ${event.title}");
    return event;
  }

  Future<void> updateEventDetails({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final eventId = ref.read(selectedEventIdProvider);
      final token = ref.read(tokenProvider).value;

      if (eventId == null || token == null) return null;

      try {
        await ref.read(apiServiceProvider).updateEvent(
          token: token,
          event: Event(
            id: eventId,
            title: title,
            description: description,
            dueDate: HelperMethods.parseDate(dueDate),
            createdDate: DateTime.now(),
            teacher: Teacher(
              id: "",
              name: "",
              email: "",
              phone: "", role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
            ),
            halaqaClass: ClassModel(
              id: "",
              teacher: Teacher(
                id: "",
                name: "",
                email: "",
                phone: "", role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
              ),
              name: "",
              description: "",
              location: "",
              startTime: "",
              endTime: "",
              days: const [],
              students: const [],
              events: const [],
              assignments: const [],
              attendanceRecords: const [],
            ),
          )
        );
        return await ref.read(apiServiceProvider).getEventDetails(token, eventId);
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