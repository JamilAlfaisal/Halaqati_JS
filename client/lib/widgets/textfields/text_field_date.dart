import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextFieldDate extends StatefulWidget {
  final TextEditingController textController;
  final String title;
  final String hintText;
  const TextFieldDate({
    super.key, required this.hintText,
    required this.textController,
    required this.title
  });

  @override
  State<TextFieldDate> createState() => _TextFieldDateState();
}

class _TextFieldDateState extends State<TextFieldDate> {
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Start with today or previously selected date
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2101), // Latest selectable date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // 3. Update the text controller with the formatted date string
        widget.textController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
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
            readOnly: true,
            onTap: ()=> _selectDate(context),
            decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // Call the date picker function

                ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
