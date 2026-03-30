import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullWidthButton extends ConsumerWidget {
  final bool isActive;
  final void Function(BuildContext context,WidgetRef ref)? onPressed;
  final String text;
  const FullWidthButton({super.key, required this.onPressed, required this.text, this.isActive = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
        ),
        onPressed: isActive?(){onPressed?.call(context, ref);}:null,
        child: Text(text),
      ),
    );
  }
}
