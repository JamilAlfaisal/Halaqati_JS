import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TextFieldNormal extends StatefulWidget {
  final TextEditingController textController;
  final String title;
  final String hintText;

  const TextFieldNormal({
    super.key, required this.hintText,
    required this.textController,
    required this.title
  });

  @override
  State<TextFieldNormal> createState() => _TextFieldNormalState();
}

class _TextFieldNormalState extends State<TextFieldNormal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        Text(
          widget.title,
          style: TextTheme.of(context).bodyLarge,
        ),
        TextFormField(
          controller: widget.textController,
          validator: (value) {
            final forbiddenPattern  = RegExp(r'^[ a-zA-Z0-9\u0600-\u06FF\u0660-\u0669\u06F0-\u06F9_-]+$');
            if (value == null || value.isEmpty) {
              return 'add_halaqah_screen.empty_halaqa_name'.tr();
            }
            if(!forbiddenPattern.hasMatch(value)){
              return 'add_halaqah_screen.only_numbers'.tr();
            }
            return null; // Return null if the input is valid
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
          ),
        ),
      ],
    );
  }
}
