import 'package:flutter/material.dart';

class FullWidthButton extends StatelessWidget {
  final bool isActive;
  final void Function(BuildContext context)? onPressed;
  final String text;
  const FullWidthButton({super.key, required this.onPressed, required this.text, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
        ),
        onPressed: isActive?(){onPressed?.call(context);}:null,
        child: Text(text),
      ),
    );
  }
}
