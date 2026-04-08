import 'package:flutter_riverpod/legacy.dart';

final isLoadingMoreProvider = StateProvider.family<bool, String>((ref, key) => false);