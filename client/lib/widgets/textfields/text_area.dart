import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TextArea extends StatelessWidget {
  final TextEditingController textController;
  final String title;
  const TextArea({
    required this.textController,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        Text(
          title,
          style: TextTheme.of(context).bodyLarge,
        ),
        TextFormField(
          controller: textController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          minLines: 5,
          validator: (value){
            // print(value);
            final forbiddenPattern  = RegExp(r'^[ a-zA-Z0-9\u0600-\u06FF\u0660-\u0669_-]+$');

            if (value == null || value.isEmpty) {
              return 'add_halaqah_screen.empty_halaqa_name'.tr();
            }
            if(!forbiddenPattern.hasMatch(value)){
             return 'add_halaqah_screen.only_letters_numbers'.tr();
            }
              return null; // Return null if the input is valid
            },
          decoration: InputDecoration(

          ),
        ),
      ],
    );
  }
}
