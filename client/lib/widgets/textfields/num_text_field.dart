import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NumTextField extends StatefulWidget {
  final TextEditingController textController;
  final String title;

  const NumTextField({
    super.key,
    required this.textController,
    required this.title
  });

  @override
  State<NumTextField> createState() => _NumTextFieldState();
}

class _NumTextFieldState extends State<NumTextField> {
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
        SizedBox(
          width: 80,
          child: TextFormField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            controller: widget.textController,
            validator: (value){
              // print(value);
              final forbiddenPattern  = RegExp(r'^[0-9\u0660-\u0669]+$');
              if (value == null || value.isEmpty) {
                return 'add_halaqah_screen.empty_halaqa_name'.tr();
              }
              if(!forbiddenPattern.hasMatch(value)){
                return 'add_halaqah_screen.only_letters_numbers'.tr();
              }
              return null; // Return null if the input is valid
            },
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Handle the capacity number change
            },
          ),
        ),
      ],
    );
  }
}
