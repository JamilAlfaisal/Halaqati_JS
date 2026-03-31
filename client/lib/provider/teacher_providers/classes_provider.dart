import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/provider/teacher_providers/profile_provider.dart';
import 'package:halqati/provider/token_notifier.dart';


final classesProvider = AsyncNotifierProvider<ClassesNotifier, List<ClassModel>?>(ClassesNotifier.new);


class ClassesNotifier extends AsyncNotifier<List<ClassModel>?> {
  @override
  Future<List<ClassModel>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    print("token class provider build: $token");
    if (token == null  || token.isEmpty) {
      print("No token found, returning empty state to stop loop.");
      return [];
    }

    try {
      return await ref.read(apiServiceProvider).getClasses(token);
    } catch (e) {
      print("error catched $e");
      if (e is UnauthorizedException) {

        print("error type UnauthorizedException");
        await AuthHelper.handleLogout(ref);
        // ref.invalidate(authProvider);
      }
      print("rethrowing catch block in class provider");
      rethrow;
    }
  }

  Future<void> createClass (
    {
      required String name,
      String description = "",
      String roomNumber = "",
      required List<int> scheduleDays,
      required String startTime,
      required String endTime,
    }
  ) async {
    final tokenAsync = ref.read(tokenProvider);

    // Wait for token to load
    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    if (token == null) {
      throw UnauthorizedException();
    }

    try{
      await ref.read(apiServiceProvider)
        .createClass(
            token: token,
            name: name,
            description: description,
            roomNumber: roomNumber,
            scheduleDays: scheduleDays,
            startTime: startTime,
            endTime: endTime,
        );
        ref.invalidateSelf();
    } catch(e){
      //e is ApiException
      if (e is UnauthorizedException) {
        print('Clearing token due to auth/API error');
        await AuthHelper.handleLogout(ref);
        // ref.invalidate(authProvider);
      }
      rethrow;
    }
  }

  Future<void> deleteClass() async {
    final tokenAsync = ref.read(tokenProvider);
    final String classId = ref.watch(selectedClassIdProvider)??"0";

    if (tokenAsync.isLoading) throw Exception('Token loading');

    final token = tokenAsync.value;
    if (token == null) throw UnauthorizedException();

    try {
      await ref.read(apiServiceProvider).deleteClass(token, classId);

      if (state.hasValue) {
        final updatedList = state.value?.where((item) => item.id != classId).toList();
        state = AsyncData(updatedList);
      }

    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }
}

final teacherStatsProvider = Provider((ref) {
  final classesAsync = ref.watch(classesProvider);

  return classesAsync.maybeWhen(
    data: (classes) {
      if (classes == null) return {'classCount': 0, 'studentCount': 0};

      int classCount = classes.length;
      // Sum up students across all classes
      int studentCount = classes.fold(0, (sum, item) => sum + (item.studentCount()));

      return {
        'classCount': classCount,
        'studentCount': studentCount,
      };
    },
    orElse: () => {'classCount': 0, 'studentCount': 0},
  );
});


class SelectedClassIdNotifier extends Notifier<String?> {
  @override
  String build() => "0";

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final selectedClassIdProvider = NotifierProvider<SelectedClassIdNotifier, String?>(
  SelectedClassIdNotifier.new,
);


final classDetailsProvider =
AsyncNotifierProvider<ClassDetailsNotifier, ClassModel?>(
  ClassDetailsNotifier.new,
);

class ClassDetailsNotifier extends AsyncNotifier<ClassModel?> {
  @override
  Future<ClassModel?> build() async {
    final classId = ref.watch(selectedClassIdProvider);
    if (classId == null) return null;

    final token = ref.watch(tokenProvider).value;
    if (token == null) return null;

    return ref.read(apiServiceProvider).getClass(token, classId);
  }

  Future<void> updateHalaqah(
      {
        required String name,
        String description = "",
        String roomNumber = "",
        required List<int> scheduleDays,
        required String startTime,
        required String endTime,
      }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {

      final classId = ref.read(selectedClassIdProvider);
      if (classId == null) return null;

      final token = ref.read(tokenProvider).value;
      if (token == null) return null;
      try{
        await ref.read(apiServiceProvider).updateClasses(
          token: token,
          name: name,
          description: description,
          roomNumber: roomNumber,
          scheduleDays: scheduleDays,
          startTime: startTime,
          endTime: endTime,
          id: classId
        );

        return await ref.read(apiServiceProvider).getClass(token, classId);
      }catch(e){
        if (e is UnauthorizedException) {
          print('Clearing token due to auth/API error');
          await AuthHelper.handleLogout(ref);
        }
        rethrow;
      }
    });
  }
}
