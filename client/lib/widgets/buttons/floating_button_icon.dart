import 'package:flutter/material.dart';

class FloatingButtonIcon extends StatelessWidget {
  final Function onPressed;
  final String text;
  const FloatingButtonIcon({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(

      onPressed: ()=> onPressed(),
      icon: const Icon(Icons.add),
      label: Text(text),
    );
  }
}
