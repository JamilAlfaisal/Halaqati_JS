

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/FeedItem.dart';

final selectedFeedItemProvider =
NotifierProvider<SelectedFeedItemNotifier, SelectedFeedItem?>(
  SelectedFeedItemNotifier.new,
);

class SelectedFeedItemNotifier extends Notifier<SelectedFeedItem?> {
  @override
  SelectedFeedItem? build() => null;

  void select(SelectedFeedItem item) {
    state = item;
  }

  void clear() {
    state = null;
  }
}

