import 'package:flutter/material.dart';

class ElevatedLight extends StatelessWidget {
  final Function onPressed;
  final String text;
  const ElevatedLight({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondary,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),

        ),
        onPressed: ()=>onPressed(),
        child: Text(text),
      ),
    );
  }
}
