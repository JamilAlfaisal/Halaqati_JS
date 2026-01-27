import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/lists/student_list.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';

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
    final classId = ref.watch(selectedClassIdProvider);

    return Scaffold(
      floatingActionButton: FloatingButtonIcon(text: "halaqah_screen.students.add_student".tr(), onPressed: (){}),
      appBar: AppbarWithButton(addBackButton: true, text: "Text",),
      body: asyncStudents.when(
          data: (studentList){
            if(studentList != null){
              students = studentList.where((student) => student.classId == classId).toList();
            }else{
              students = [];
            }
            return RefreshIndicator(
              onRefresh: () async {
                final freshStudents = await ref.refresh(studentsProvider.future);

                setState(() {
                  if (freshStudents != null) {
                    students = freshStudents.where((s) => s.classId == classId).toList();
                    searchedStudents = students;
                  }
                  search.clear();
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  spacing: 10,
                  children: [
                    TextFieldSearch(
                      textController: search,
                      hintText: "halaqah_screen.students.search".tr(),
                      onChange: (value){
                        setState(() {
                          if(value.isEmpty){
                            searchedStudents = students;
                          }else{
                            final List<Student> filtered = students.where((student){
                              return student.name != null && student.name!.toLowerCase().trim().contains(
                                  search.text.toLowerCase().trim());
                            }).toList();
                            searchedStudents = filtered;
                          }
                        });
                      },
                    ),
                    searchedStudents.isNotEmpty?
                    Expanded(
                      child: ListView.builder(
                          itemCount: searchedStudents.length,
                          itemBuilder: (context, index){
                            return StudentList(
                                name: searchedStudents[index].name ?? "Name not found",
                                totalPagesMemorized: searchedStudents[index].memorizedPages?.length ?? 0,
                                onTap: (){
                                  ref.watch(selectedStudentIdProvider.notifier).select(searchedStudents[index].id??0);
                                  Navigator.of(context).pushNamed('/student_bottom_appbar');
                                }
                            );
                          }
                      ),
                    ):Expanded(
                      child: ListView(
                        children: [
                          Center(
                              child: Text(
                                "halaqah_screen.students.no_students".tr(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
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

