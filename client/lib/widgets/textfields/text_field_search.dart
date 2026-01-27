import 'package:flutter/material.dart';

class TextFieldSearch extends StatelessWidget {
  final TextEditingController textController;
  final void Function(String value) onChange;
  final String hintText;

  const TextFieldSearch({
    super.key, required this.hintText,
    required this.textController,
    required this.onChange
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search),
        ),
      onChanged: onChange,
    );
  }
}
