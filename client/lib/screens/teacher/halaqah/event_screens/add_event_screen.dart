import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
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

  final TextEditingController title = TextEditingController();
  final TextEditingController des = TextEditingController();
  final TextEditingController date = TextEditingController(text: HelperMethods.formatDate(DateTime.now()));
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
          content: Text('${"error".tr()}: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('created_success'.tr()),
      )
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    return Scaffold(
      appBar: AppbarWithButton(
          text: halaqahName,
          addBackButton: true
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFieldNormal(
                hintText: "${"enter".tr()} ${"title".tr()}",
                textController: title,
                title: "title".tr()
            ),
            TextArea(
                textController: des,
                title: "des".tr()
            ),
            const SizedBox(height: 20),
            CustomDatePicker(
              label: "due_date".tr(),
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
              text: "create".tr(),
              ability: !ref.watch(eventProvider).isLoading,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }
}