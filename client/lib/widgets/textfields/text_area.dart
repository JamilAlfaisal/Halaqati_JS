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

          decoration: InputDecoration(
            errorMaxLines: 3,
            border: OutlineInputBorder(),
          ),

          validator: (value){
            final forbiddenPattern = RegExp(r'^[ a-zA-Z0-9\u0600-\u06FF\u0660-\u0669_{}():*,.,. \- \? ؟ !\n\r]+$');

            if (value == null || value.isEmpty) {
              return 'empty'.tr();
            }
            if(!forbiddenPattern.hasMatch(value)){
             return 'area_text_field'.tr();
            }
              return null;
            },
        ),
      ],
    );
  }
}
