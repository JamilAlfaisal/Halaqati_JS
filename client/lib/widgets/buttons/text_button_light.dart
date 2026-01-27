import 'package:flutter/material.dart';

class TextButtonLight extends StatelessWidget {
  final Function onPressed;
  final String text;
  const TextButtonLight({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: ()=>onPressed(),
        child: Text(text),
    );
  }
}
