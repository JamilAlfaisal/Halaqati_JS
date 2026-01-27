import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class TextPhone extends StatefulWidget {
  final TextEditingController textController;
  final String title;
  final String hintText;

  const TextPhone({
    super.key,
    required this.hintText,
    required this.textController,
    required this.title,
  });

  @override
  State<TextPhone> createState() => _TextPhoneState();
}

class _TextPhoneState extends State<TextPhone> {
  String countryCode = "+1"; // default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          widget.title,
          style: TextTheme.of(context).bodyLarge,
        ),

        TextFormField(
          controller: widget.textController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final forbiddenPattern  = RegExp(r'^[0-9\u0660-\u0669]+$');
            print(value);
            if (value == null || value.isEmpty) {
              return 'text_phone.empty'.tr();
            }
            if(!forbiddenPattern.hasMatch(value)){
              return 'text_phone.invalid_phone'.tr();
            }
            return null; // Return null if the input is valid
          },
          decoration: InputDecoration(
            hintText: widget.hintText,

            // === Country Code Picker Here ===
            prefixIcon: CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  countryCode = code.dialCode!;
                });
              },
              initialSelection: 'LB',
              showDropDownButton: true,
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
              padding: EdgeInsetsGeometry.zero,
            ),
          ),
        ),
      ],
    );
  }
}
