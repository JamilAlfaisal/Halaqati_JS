import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/country_code_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/textfields/text_field_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/lists/student_list.dart';
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
      // floatingActionButton: FloatingButtonIcon(
      //   text: "${"add".tr()} ${"students".tr()}",
      //   onPressed: (){
      //     _showAddStudentSheet(context, ref);
      //   }
      // ),
        appBar: AppbarExtraButton(
          text: halaqahName,
          addBackButton: true,
          icon: Icon(
            Icons.person_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPress: () async {
            _showAddStudentSheet(context, ref);
          },
        ),
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
                              return student.name.toLowerCase().trim().contains(
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
                              name: searchedStudents[index].name,
                              profileUrl: searchedStudents[index].picProfile  ,
                              totalPagesMemorized: searchedStudents[index].memorizedJuz.length,
                              onTap: (){
                                ref.read(selectedStudentNameProvider.notifier).setName(searchedStudents[index].name);
                                ref.watch(selectedStudentIdProvider.notifier).select(searchedStudents[index].id);
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
                return ref.invalidate(studentsProvider);
              },
              child: CustomErrorWidget(
                providerToInvalidate: studentsProvider,
              )
            );
          },
          loading: () => LoadingWidget()
      )
    );
  }
}

void _showAddStudentSheet(BuildContext context, WidgetRef ref) {
  final TextEditingController phoneController = TextEditingController();
  bool ability = true;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                  hintText: "phone".tr(),
                  textController: phoneController,
                  title: "student_phone_number".tr()
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ability?() async {
                    setModalState(() => ability = false);
                    ability = false;
                    final String phoneCountryCode = ref.watch(countryCodeProvider)??"+961";
                    final phone = phoneController.text.trim();

                    if (phone.isEmpty) {
                      setModalState(() => ability = true);
                      return;
                    }

                    try {
                      await ref.read(studentsProvider.notifier).addStudent(phoneCountryCode+phone);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('added_success'.tr())),
                        );
                      }
                      setModalState(() => ability = true);
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('error'.tr()), backgroundColor: Colors.red),
                      );
                    }
                  }:null,
                  child: Text("add".tr()),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
          );
        }
      );
    },
  );
}