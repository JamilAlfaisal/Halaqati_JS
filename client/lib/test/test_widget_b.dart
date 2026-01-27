import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/test/provider_tester.dart';

class TestWidgetB extends ConsumerStatefulWidget {
  const TestWidgetB({super.key});

  @override
  ConsumerState<TestWidgetB> createState() => _TestWidgetAState();
}

class _TestWidgetAState extends ConsumerState<TestWidgetB> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(onPressed: (){
              ref.read(counterNotifierProvider.notifier).increment();
            }, icon: Icon(Icons.plus_one)
          ),
          IconButton(onPressed: (){
            ref.read(counterNotifierProvider.notifier).decrement();
          }, icon: Icon(Icons.exposure_minus_1)
          ),
        ],
      ),
    );
  }
}
