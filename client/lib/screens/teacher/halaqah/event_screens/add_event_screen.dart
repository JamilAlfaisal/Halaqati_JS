import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/teacher_providers/events_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/textfields/custome_date_picker.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  // 1. Controllers start empty for a "Create" screen
  final TextEditingController title = TextEditingController();
  final TextEditingController des = TextEditingController();
  final TextEditingController date = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(eventProvider.notifier).createEvent(
      title: title.text,
      description: des.text,
      dueDate: date.text,
    );

    final state = ref.read(eventProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We don't need .when() here because we aren't fetching an existing event
    return Scaffold(
      appBar: AppbarWithButton(
          text: "Add New Event".tr(), // Adjust your localization key
          addBackButton: true
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFieldNormal(
                hintText: "student_bottom_appbar.add_halaqah_screen.assignment_title".tr(),
                textController: title,
                title: "student_bottom_appbar.add_halaqah_screen.assignment_title".tr()
            ),
            TextArea(
                textController: des,
                title: "student_bottom_appbar.add_halaqah_screen.description".tr()
            ),
            const SizedBox(height: 20),
            CustomDatePicker(
              label: "Due Date",
              onDateSelected: (selectedDate) {
                setState(() {
                  date.text = HelperMethods.formatDate(selectedDate);
                });
              },
              selectedDate: date.text.isEmpty
                  ? DateTime.now()
                  : HelperMethods.parseDate(date.text),
            ),
            const SizedBox(height: 40),
            ElevatedDark(
              onPressed: createEvent,
              text: "Create Event".tr(),
              ability: true,
            ),
          ],
        ),
      ),
    );
  }
}