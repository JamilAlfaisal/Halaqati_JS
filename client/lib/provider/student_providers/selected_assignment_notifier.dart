import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedAssignmentNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final selectedAssignmentProvider = NotifierProvider<SelectedAssignmentNotifier, int?>(
  SelectedAssignmentNotifier.new,
);