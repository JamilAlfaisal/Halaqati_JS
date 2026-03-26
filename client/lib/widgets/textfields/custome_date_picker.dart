import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Remember: flutter pub get if not added

class CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true, // Prevents the keyboard from appearing
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        // Shows the date if selected, otherwise empty
        hintText: selectedDate == null
            ? 'Select Date'
            : DateFormat('yyyy-MM-dd').format(selectedDate!),
      ),
      // This controller ensures the text updates when the date changes
      controller: TextEditingController(
        text: selectedDate == null
            ? ""
            : DateFormat('yyyy-MM-dd').format(selectedDate!),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      // Add Arabic support if needed
      locale: const Locale('en', 'US'),
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
}