import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/assignment_class.dart';

class AddAssignmentScreen extends ConsumerStatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  ConsumerState<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}


class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController loc = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool ability = true;
  String? selectedValue = 'memorizing';
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
      // borderRadius: BorderRadius.circular(16), // Rounds the dialog corners
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<int> pageNumbers = [];
  final TextEditingController _pageController = TextEditingController();

  void _addPage(String value) {
    final int? page = int.tryParse(value.trim());
    if (page != null && !pageNumbers.contains(page)) {
      setState(() {
        pageNumbers.add(page);
        _pageController.clear(); // Clear input for the next number
      });
    } else {
      _pageController.clear(); // Clear even if invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentNotifier = ref.read(assignmentProvider.notifier);
    final int ?studentId = ref.watch(selectedStudentIdProvider)??0;

    final List<Map<String, String>> dropdownItems = [
      {'value': 'revision', 'label': 'student_bottom_appbar.add_halaqah_screen.revision'.tr()},
      {'value': 'memorizing', 'label': 'student_bottom_appbar.add_halaqah_screen.memorization'.tr()},
      {'value': 'reading', 'label': 'student_bottom_appbar.add_halaqah_screen.reading'.tr()},
    ];
    void handleCreateAssignment() async {
      if(selectedDate == null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('student_bottom_appbar.add_halaqah_screen.select_date'.tr()),
            // backgroundColor: Colors.green,
          ),
        );
        return;
      }
      setState(() {
        ability = false;
      });
      if (!_formKey.currentState!.validate()) {
        setState(() {
          ability = true;
        });
        return;
      }

      try{
        print(dateText);
        await assignmentNotifier.createAssignment(
          AssignmentClass(
            title: title.text,
            description: des.text,
            assignedDate: dateText,
            pages: pageNumbers,
            studentId: studentId,
            type: selectedValue
          )
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('student_bottom_appbar.add_halaqah_screen.success'.tr()),
            // backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } on ValidationException catch (e){
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } on NetworkException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('add_halaqah_screen.network_error'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on UnauthorizedException {
        if (mounted) {
          await AuthHelper.handleLogout(ref as Ref);
        }

      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("add_halaqah_screen.error_title".tr()),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            ability = true;
          });
        }
      }
    }
    return Scaffold(
      appBar: AppbarWithButton(
        text: "student_bottom_appbar.add_halaqah_screen.title".tr(),
        addBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "student_bottom_appbar.add_halaqah_screen.page_num_title".tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      // padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          // 1. The Chips Area
                          Wrap(
                            spacing: 8,
                            children: pageNumbers.map((page) {
                              return Chip(
                                label: Text(
                                  page.toString(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                onDeleted: () {
                                  setState(() => pageNumbers.remove(page),);
                                },
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor, // Change this to your desired color
                                  width: 1.0,               // Thickness of the border
                                ),
                                // 2. Control the rounded corners here
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                // backgroundColor: Colors.deepPurple.shade50,
                                deleteIconColor: Theme.of(context).primaryColor,
                              );
                            }).toList(),
                          ),
                          // 2. The Input Field
                          TextField(
                            controller: _pageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "student_bottom_appbar.add_halaqah_screen.page_num".tr(),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onSubmitted: (value) => _addPage(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(16), // Matches container shape
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateText,
                            style: TextTheme.of(context).bodyLarge,
                          ),
                          Icon(
                            Icons.calendar_month_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(16), // This makes the border circular
                    border: Border.all(color: Colors.grey.shade300, width: 2), // Border styling
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical:4),
                  child: DropdownButton<String>(
                    // Ensure 'selectedValue' is one of: 'revision', 'memorization', or 'reading'
                    value: selectedValue,
                    items: dropdownItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'], // The logic key (never changes with language)
                        child: Text(item['label']!), // The translated text (changes with language)
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    style: Theme.of(context).textTheme.bodyLarge,
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down_rounded),
                  )
                ),
                ElevatedDark(
                  onPressed: (){
                    handleCreateAssignment();
                  },
                  text: "add_halaqah_screen.create_button".tr(),
                  ability: ability,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
