import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const FilterButton({super.key, required this.onPressed, required this.text});

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
            Theme.of(context).colorScheme.secondaryContainer,
          ),

          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),

        ),
        onPressed: ()=>onPressed,
        child: Text(text),
      ),
    );
  }
}
