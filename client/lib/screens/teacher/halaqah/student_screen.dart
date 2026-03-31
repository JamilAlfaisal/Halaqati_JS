import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/textfields/text_field_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/lists/student_list.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/textfields/text_phone.dart';

class StudentScreen extends ConsumerStatefulWidget {
  const StudentScreen({super.key});

  @override
  ConsumerState<StudentScreen> createState() => _HalaqahScreenState();
}

class _HalaqahScreenState extends ConsumerState<StudentScreen> {
  final TextEditingController search = TextEditingController();
  
  late List<Student> students =  [];
  late List<Student> searchedStudents = students;

  @override
  Widget build(BuildContext context) {
    final asyncStudents = ref.watch(studentsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    return Scaffold(
      floatingActionButton: FloatingButtonIcon(
        text: "${"add".tr()} ${"students".tr()}",
        onPressed: (){
          _showAddStudentSheet(context, ref);
        }
      ),
      appBar: AppbarWithButton(addBackButton: true, text: halaqahName,),
      body: asyncStudents.when(
          data: (studentList){
            students = studentList??[];
            return RefreshIndicator(
              onRefresh: () async {
                final freshStudents = await ref.refresh(studentsProvider.future);

                setState(() {
                  if (freshStudents != null) {
                    students = studentList??[];
                    searchedStudents = students;
                  }
                  search.clear();
                });
              },
              child: Column(
                spacing: 10,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFieldSearch(
                      textController: search,
                      hintText: "${"search".tr()} ${"students".tr()}",
                      onChange: (value){
                        setState(() {
                          if(value.isEmpty){
                            searchedStudents = students;
                          }else{
                            final List<Student> filtered = students.where((student){
                              return student.name != null && student.name.toLowerCase().trim().contains(
                                  search.text.toLowerCase().trim());
                            }).toList();
                            searchedStudents = filtered;
                          }
                        });
                      },
                    ),
                  ),
                  searchedStudents.isNotEmpty?
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: searchedStudents.length,
                        itemBuilder: (context, index){
                          return StudentList(
                              name: searchedStudents[index].name ?? "Name not found",
                              totalPagesMemorized: searchedStudents[index].memorizedJuz?.length ?? 0,
                              onTap: (){
                                ref.read(selectedStudentNameProvider.notifier).setName(searchedStudents[index].name);
                                ref.watch(selectedStudentIdProvider.notifier).select(searchedStudents[index].id??"0");
                                Navigator.of(context).pushNamed('/student_bottom_appbar');
                              }
                          );
                        }
                    ),
                  ):Expanded(
                    child: EmptyStateView()
                  )
                ],
              ),
            );
          },
          error: (e, stack) {
            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () async {
                // This invalidates the provider and fetches fresh data
                return ref.invalidate(studentsProvider);
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading halaqat",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // ✅ Add retry button for errors
                    ElevatedButton(
                      onPressed: () => ref.invalidate(studentsProvider),
                      child: Text("home_screen.retry".tr()),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator())
      )
    );
  }
}

void _showAddStudentSheet(BuildContext context, WidgetRef ref) {
  final TextEditingController phoneController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Student".tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            TextPhone(
              hintText: "enter student phone number",
              textController: phoneController,
              title: "student phone number"
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  if (phone.isEmpty) return;

                  try {
                    await ref.read(studentsProvider.notifier).addStudent(phone);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student added successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text("create".tr()),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      );
    },
  );
}