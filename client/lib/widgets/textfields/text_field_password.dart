import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TextFieldPassword extends StatefulWidget {
  final TextEditingController textController;
  final String title;
  final String hintText;
  const TextFieldPassword({
    super.key, required this.hintText,
    required this.textController,
    required this.title
});

  @override
  State<TextFieldPassword> createState() => _TextFieldPasswordState();
}

class _TextFieldPasswordState extends State<TextFieldPassword> {
  bool display = false;
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
            final forbiddenPattern  = RegExp(r'^[a-zA-Z0-9_-]+$');
            print(value);
            if (value == null || value.isEmpty) {
              return 'text_field_password.empty'.tr();
            }
            if(!forbiddenPattern.hasMatch(value)){
              return 'text_field_password.invalid_characters'.tr();
            }
            return null; // Return null if the input is valid
          },
          obscureText: !display,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: IconButton(
                onPressed: (){
                  setState(() {
                    display = !display;
                  });
                },
                icon: Icon(display?Icons.visibility:Icons.visibility_off)
            )
          ),
        ),
      ],
    );
  }
}
