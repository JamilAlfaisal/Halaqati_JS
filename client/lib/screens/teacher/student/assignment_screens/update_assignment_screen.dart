import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateAssignmentScreen extends ConsumerStatefulWidget {
  const UpdateAssignmentScreen({super.key});

  @override
  ConsumerState<UpdateAssignmentScreen> createState() => _AddAssignmentScreenState();
}


class _AddAssignmentScreenState extends ConsumerState<UpdateAssignmentScreen> {

  TextEditingController title = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController loc = TextEditingController();
  bool isInitialized = false;
  final _formKey = GlobalKey<FormState>();
  bool ability = true;
  String? selectedValue = 'Memorization';
  DateTime? selectedDate;

  String get dateText {
    if (selectedDate == null) return "student_bottom_appbar.add_halaqah_screen.date_hint".tr();
    return "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<String> pageNumbers = [];
  final TextEditingController _pageController = TextEditingController();

  void _addPage(String value) {
    final int? page = int.tryParse(value.trim());
    if (page != null && !pageNumbers.contains(page)) {
      setState(() {
        pageNumbers.add(page.toString());
        _pageController.clear();
      });
    } else {
      _pageController.clear(); // Clear even if invalid
    }
  }

  final List<Map<String, String>> dropdownItems = [
    {'value': 'Revision', 'label': 'student_bottom_appbar.add_halaqah_screen.revision'.tr()},
    {'value': 'Memorization', 'label': 'student_bottom_appbar.add_halaqah_screen.memorization'.tr()},
    {'value': 'Reading', 'label': 'student_bottom_appbar.add_halaqah_screen.reading'.tr()},
  ];

  @override
  Widget build(BuildContext context) {

    final asyncAssignment = ref.watch(activeAssignmentProvider);
    final assignmentNotifier = ref.read(assignmentProvider.notifier);
    final studentId = ref.watch(selectedStudentIdProvider);

    // 2. We wrap the handleUpdate inside the build to access the latest state
    void handleUpdateAssignment() async {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('student_bottom_appbar.add_halaqah_screen.select_date'.tr())),
        );
        return;
      }

      setState(() => ability = false);
      if (!_formKey.currentState!.validate()) {
        setState(() => ability = true);
        return;
      }

      try {
        await assignmentNotifier.updateAssignmentDetails(
          title: title.text,
          description: des.text,
          pages: pageNumbers.map((page) => int.parse(page)).toList(),
          studentsIds: [int.parse(studentId ?? "0")],
          type: selectedValue ?? 'Memorization',
          dueDate: HelperMethods.formatDate(selectedDate),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('student_bottom_appbar.update.success'.tr())),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (e is UnauthorizedException) {
          await AuthHelper.handleLogout(ref);
        }
        rethrow;
      } finally {
        if (mounted) setState(() => ability = true);
      }
    }

    if (!isInitialized) {
      title.text = asyncAssignment?.title??"";
      des.text = asyncAssignment?.description??"";
      selectedDate = asyncAssignment?.dueDate??DateTime.now();
      selectedValue = asyncAssignment?.type??"";
      pageNumbers = List.from(asyncAssignment?.pages??[]);
      isInitialized = true;
    }

    return Scaffold(
      appBar: AppbarWithButton(
        text: "Update".tr(),
        addBackButton: true,
      ),
      body: asyncAssignment == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldNormal(
                    hintText: "student_bottom_appbar.add_halaqah_screen.assignment_title".tr(),
                    textController: title,
                    title: "student_bottom_appbar.add_halaqah_screen.assignment_title".tr()
                ),
                const SizedBox(height: 10),
                TextArea(
                    textController: des,
                    title: "student_bottom_appbar.add_halaqah_screen.description".tr()
                ),
                const SizedBox(height: 10),

                // --- PAGE NUMBERS SECTION ---
                Text(
                  "student_bottom_appbar.add_halaqah_screen.page_num_title".tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: pageNumbers.map((page) => Chip(
                    label: Text(page, style: Theme.of(context).textTheme.bodyLarge),
                    onDeleted: () => setState(() => pageNumbers.remove(page)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    deleteIconColor: Theme.of(context).primaryColor,
                  )).toList(),
                ),
                TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "student_bottom_appbar.add_halaqah_screen.page_num".tr(),
                  ),
                  onSubmitted: (value) => _addPage(value),
                ),
                const SizedBox(height: 20),

                // --- DATE PICKER ---
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateText, style: Theme.of(context).textTheme.bodyLarge),
                        const Icon(Icons.calendar_month_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- TYPE DROPDOWN ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      items: dropdownItems.map((item) => DropdownMenuItem(
                        value: item['value'],
                        child: Text(
                          item['label']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedValue = val),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedDark(
                  onPressed: handleUpdateAssignment,
                  text: "Update".tr(),
                  ability: ability,
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}