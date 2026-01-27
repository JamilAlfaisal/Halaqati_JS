import 'package:flutter/material.dart';

class VerseNumber extends StatelessWidget {
  final bool selected;
  final VoidCallback  onPressed;
  final String num;
  const VerseNumber({super.key, required this.onPressed, required this.num, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ElevatedButton(
            onPressed: onPressed,
            style: selected
        ?ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
            ),
          ),
        )
        :ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondary,
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
            ),
          ),
        ),
        child: Text(num),
      ),
    );
  }
}
