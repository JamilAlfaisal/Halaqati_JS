import 'package:flutter/material.dart';

class PageNumber extends StatelessWidget {
  final bool selected;
  final VoidCallback  onPressed;
  final int num;
  const PageNumber({super.key, required this.onPressed, required this.num, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: selected?Theme.of(context).colorScheme.primary:Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.all(Radius.circular(16))
        ),
        child: Text(
          "$num",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15
          ),
        ),
      ),
    );
  }
}
