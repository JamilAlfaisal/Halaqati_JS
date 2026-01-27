import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/test/provider_tester.dart';

class TestWidgetA extends ConsumerStatefulWidget {
  const TestWidgetA({super.key});

  @override
  ConsumerState<TestWidgetA> createState() => _TestWidgetAState();
}

class _TestWidgetAState extends ConsumerState<TestWidgetA> {
  @override
  Widget build(BuildContext context) {
    final num = ref.watch(counterNotifierProvider);
    return Container(
      child: Text('$num'),
    );
  }
}
