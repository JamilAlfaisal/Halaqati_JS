import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:halqati/provider/token_notifier.dart';

final assignmentProvider = AsyncNotifierProvider<AssignmentNotifier, List<AssignmentClass>?>(AssignmentNotifier.new);

class AssignmentNotifier extends AsyncNotifier<List<AssignmentClass>?>{
  @override
  FutureOr<List<AssignmentClass>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

    if (tokenAsync.isLoading) {
      throw Exception('Token loading');
    }

    final token = tokenAsync.value;
    print("token class provider build: $token");
    if (token == null  || token.isEmpty) {
      // throw UnauthorizedException();
      print("No token found, returning empty state to stop loop.");
      return [];
    }
    try{
      print("try to get assignment List");
      return await ref.read(apiServiceProvider).getAssignments(token)??[];
    }catch(e){
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
    return [];
  }
  Future<void> createAssignment (
        AssignmentClass assignment
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
          .createAssignment(token, assignment);
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
}
