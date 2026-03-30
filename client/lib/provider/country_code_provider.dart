


import 'package:flutter_riverpod/flutter_riverpod.dart';

class countryCodeNotifier extends Notifier<String?> {
  @override
  String build() => "+961";

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

final countryCodeProvider = NotifierProvider<countryCodeNotifier, String?>(
  countryCodeNotifier.new,
);