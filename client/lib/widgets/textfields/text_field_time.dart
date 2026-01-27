import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TextFieldTime extends StatefulWidget {
  final TextEditingController textController;
  final String title;

  const TextFieldTime({
    super.key,
    required this.textController,
    required this.title
  });

  @override
  State<TextFieldTime> createState() => _NumTextFieldState();
}

class _NumTextFieldState extends State<TextFieldTime> {

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Handle the selected time here (e.g., update a state variable)
      print('Selected time: ${picked.format(context)}');
      final String formattedTime = picked.format(context);
      setState(() {
        widget.textController.text = formattedTime;
      });
    }else{

    }
  }
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
          width: 140,
          child: TextFormField(
            keyboardType: TextInputType.none,
            textAlign: TextAlign.center,
            controller: widget.textController,
            validator: (value){
              // print(value);
              if (value == null || value.isEmpty) {
                return 'add_halaqah_screen.empty_halaqa_name'.tr();
              }
              return null; // Return null if the input is valid
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(onPressed: (){_selectTime(context);}, icon: const Icon(Icons.timer_sharp))
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
