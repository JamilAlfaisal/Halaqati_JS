import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/grades_notifier.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';

class SetGradeOnAssignment extends ConsumerStatefulWidget {
  final String assignmentId;
  final String assignmentName;
  const SetGradeOnAssignment({
    super.key,
    required this.assignmentId,
    required this.assignmentName
  });

  @override
  ConsumerState<SetGradeOnAssignment> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends ConsumerState<SetGradeOnAssignment> {
  late TextEditingController scoreController = TextEditingController();
  // late TextEditingController weightController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  int selectedWeight = 1;
  final _formKey = GlobalKey<FormState>();
  bool ability = true;


  // @override
  // void initState() {
  //   super.initState();
  //   scoreController = TextEditingController(text:"0");
  //   weightController = TextEditingController();
  //   descriptionController = TextEditingController();
  // }

  @override
  void dispose() {
    scoreController.dispose();
    // weightController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final double? score = double.tryParse(scoreController.text);
    // final int? weight = int.tryParse(weightController.text);

    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalid_input'.tr()), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => ability = false);
    final notifier = ref.read(gradesProvider.notifier);

    try {

        await notifier.addGrade(
          score: score,
          weight: selectedWeight,
          description: descriptionController.text,
          assignmentId: widget.assignmentId,
        );

        await ref.read(assignmentProvider.notifier).refreshAssignments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('saved_success'.tr())),
        );
        Navigator.pop(context);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
        );
      }
    } on UnauthorizedException {
      if (mounted) await AuthHelper.handleLogout(ref);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error'.tr()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => ability = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String halaqahName = ref.watch(selectedClassNameProvider) ?? "name".tr();
    final String studentName = ref.watch(selectedStudentNameProvider) ?? "name".tr();
    final languageCode = context.locale.languageCode;

    return Scaffold(
      appBar: AppbarWithButton(
        text: halaqahName,
        addBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                CustomLabel(text: studentName),

                // Display assignment title if it exists
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "assignment".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    widget.assignmentName,
                                    style: Theme.of(context).textTheme.bodyLarge
                                ),
                              ),
                              IconButton(
                                  onPressed: (){
                                    ref.read(selectedAssignmentProvider.notifier).select(int.parse((widget.assignmentId??"0").toString()));
                                    Navigator.of(context).pushNamed("/update_assignment_screen");
                                  },
                                  icon: languageCode == "ar"
                                      ? Icon(Icons.arrow_circle_left)
                                      : Icon(Icons.arrow_circle_right_sharp)
                              )
                            ],
                          )
                      ),
                    ],
                  ),

                TextFieldNormal(
                  hintText: "0.0 - 20.0",
                  textController: scoreController,
                  title: "score".tr(),
                ),

                // TextFieldNormal(
                //   hintText: "1",
                //   textController: weightController,
                //   title: "weight".tr(),
                // ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'select_weight'.tr(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(value: 1, label: Text('1')),
                        ButtonSegment<int>(value: 2, label: Text('2')),
                        ButtonSegment<int>(value: 3, label: Text('3')),
                      ],
                      selected: <int>{selectedWeight},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          selectedWeight = newSelection.first;
                        });
                      },
                      // Style customizations (Optional)
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                        selectedForegroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                TextArea(
                  textController: descriptionController,
                  title: "notes".tr(),
                ),

                const SizedBox(height: 10),

                ElevatedDark(
                  onPressed: handleSave,
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
}