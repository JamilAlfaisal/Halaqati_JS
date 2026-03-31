import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class selectedNameNotifier extends Notifier<String?> {
  @override
  String build() => "name".tr();

  void setName(String name) {
    state = name;
  }

  void clear() {
    state = null;
  }
}

final selectedStudentNameProvider = NotifierProvider<selectedNameNotifier, String?>(
  selectedNameNotifier.new,
);