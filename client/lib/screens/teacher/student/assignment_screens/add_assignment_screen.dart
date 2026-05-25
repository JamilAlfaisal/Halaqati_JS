import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:halqati/widgets/lists/StudentAssignmentList.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:easy_localization/easy_localization.dart';


class AddAssignmentScreen extends ConsumerStatefulWidget {
  final bool? forManyStudents; // Nullable attribute as requested
  const AddAssignmentScreen({super.key, this.forManyStudents});

  @override
  ConsumerState<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController des = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool ability = true;
  String? selectedValue = 'Memorization';
  DateTime? selectedDate;

  List<String> pageNumbers = [];
  final TextEditingController _pageController = TextEditingController();

  // Track selected IDs for many-student mode
  List<String> selectedStudentsIds = [];

  String get dateText {
    if (selectedDate == null) return "select_date".tr();
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
      setState(() => selectedDate = picked);
    }
  }

  void _addPage(String value) {
    final int? page = int.tryParse(value.trim());
    if (page != null && !pageNumbers.contains(page.toString())) {
      setState(() {
        pageNumbers.add(page.toString());
        _pageController.clear();
      });
    } else {
      _pageController.clear();
    }
  }

  void handleCreateAssignment() async {
    final assignmentNotifier = ref.read(assignmentProvider.notifier);
    final isMulti = widget.forManyStudents ?? false;

    // Final check for student selection
    List<String> finalStudentIds = isMulti
        ? selectedStudentsIds
        : [ref.read(selectedStudentIdProvider) ?? ""];

    if (finalStudentIds.isEmpty || (finalStudentIds.length == 1 && finalStudentIds[0] == "")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_at_least_one_student'.tr())),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('select_date'.tr())));
      return;
    }

    setState(() => ability = false);
    if (!_formKey.currentState!.validate()) {
      setState(() => ability = true);
      return;
    }

    try {
      await assignmentNotifier.createAssignment(
        title: title.text,
        description: des.text,
        pages: pageNumbers,
        type: selectedValue ?? "Memorization",
        studentsIds: finalStudentIds,
        dueDate: HelperMethods.formatDate(selectedDate!),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('created_success'.tr())));
      Navigator.pop(context);
    } catch (e) {
      // Error handling kept consistent with your original code
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => ability = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMulti = widget.forManyStudents ?? false;
    final String halaqahName = ref.watch(selectedClassNameProvider) ?? "name".tr();
    final String studentName = ref.watch(selectedStudentNameProvider) ?? "name".tr();
    final List<Student> allStudents = ref.watch(studentsProvider).value ?? [];

    final List<Map<String, String>> dropdownItems = [
      {'value': 'Revision', 'label': 'revision'.tr()},
      {'value': 'Memorization', 'label': 'memorization'.tr()},
      {'value': 'Reading', 'label': 'reading'.tr()},
    ];

    return Scaffold(
      appBar: AppbarWithButton(text: halaqahName, addBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // Display specific student name ONLY if it's a single assignment
                if (!isMulti) CustomLabel(text: studentName),

                TextFieldNormal(hintText: "title".tr(), textController: title, title: "title".tr()),
                TextArea(textController: des, title: "des".tr()),

                // Page selection logic
                _buildPageSelection(),

                // Date Picker
                _buildDatePicker(),

                // Type Dropdown
                _buildTypeDropdown(dropdownItems),

                // Multi-student selection list
                if (isMulti) ...[
                  const Divider(height: 30),
                  CustomLabel(text: "select_students".tr()),
                  ...allStudents.asMap().entries.map((entry) {
                    int index = entry.key;
                    Student student = entry.value;
                    bool isSelected = selectedStudentsIds.contains(student.id);

                    return StudentAssignmentTile(
                      isSelected: isSelected,
                      name: student.name,
                      onToggle: (value) {
                        setState(() {
                          if (value == true) {
                            selectedStudentsIds.add(student.id);
                          } else {
                            selectedStudentsIds.remove(student.id);
                          }
                        });
                      },
                      // Static values for creation mode
                      score: 0.0,
                      weight: 0,
                      description: "",
                      id: "",
                    );
                  }).toList(),
                ],

                const SizedBox(height: 20),
                ElevatedDark(
                  onPressed: handleCreateAssignment,
                  text: "create".tr(),
                  ability: ability,
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Component Helpers ---

  Widget _buildPageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("pages".tr(), style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: pageNumbers.map((page) => Chip(
            label: Text(page, style: Theme.of(context).textTheme.bodyLarge),
            onDeleted: () => setState(() => pageNumbers.remove(page)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Theme.of(context).primaryColor),
          )).toList(),
        ),
        TextField(
          controller: _pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "page_num".tr(), border: InputBorder.none),
          onSubmitted: _addPage,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateText, style: Theme.of(context).textTheme.bodyLarge),
              const Icon(Icons.calendar_month_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items: items.map((item) => DropdownMenuItem(
            value: item['value'],
            child: Text(item['label']!),
          )).toList(),
          onChanged: (val) => setState(() => selectedValue = val),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}