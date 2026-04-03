import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/attendance_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/student_attendance_item.dart';
import 'package:halqati/widgets/loading_widget.dart';

class AttendacneDetailsSceen extends ConsumerStatefulWidget {
  const AttendacneDetailsSceen({super.key});

  @override
  ConsumerState<AttendacneDetailsSceen> createState() => _AttendacneDetailsSceenState();
}

class _AttendacneDetailsSceenState extends ConsumerState<AttendacneDetailsSceen> {

  late List<int> selectedStudents = [];
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {

    final attendancesAsync = ref.watch(attendanceDetailsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final asyncStudents = ref.watch(studentsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(halaqahName),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceProvider);
        },
        child: attendancesAsync.when(
          data: (attendances) {
            final List<Student> data = attendances.students;

            if (!isInitialized){
              selectedStudents = data
                  .map((student) => int.tryParse(student.id))
                  .whereType<int>()
                  .toList();
              isInitialized = true;
            }

            return Column(
              children: [
                CustomLabel(text: HelperMethods.formatDate(attendances.date)),
                SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    itemCount: asyncStudents?.length??0,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    itemBuilder: (context, index){

                      return StudentAttendanceItem(
                        onChanged: (isSelected){
                          if (selectedStudents.contains(int.tryParse(asyncStudents?[index].id??"0")??0)){
                            setState(() {
                              selectedStudents.remove(int.tryParse(asyncStudents?[index].id??"0")??0);
                            });
                          }else{
                            setState(() {
                              selectedStudents.add(int.tryParse(asyncStudents?[index].id??"0")??0);
                            });
                          }
                        },
                        isSelected: selectedStudents.contains(int.tryParse(asyncStudents?[index].id??"0")??0),
                        studentName: asyncStudents?[index].name??"name",
                        subtitle: "${asyncStudents?[index].memorizedJuz.length??"0"}",
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref.read(attendanceProvider.notifier).updateAttendance(
                        studentIds: selectedStudents,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("created_success".tr())),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: Text("update".tr()),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom+20,
                )
              ],
            );
          },
          loading: () => LoadingWidget(),
          error: (e, stack) {
            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomErrorWidget(
              providerToInvalidate: attendanceDetailsProvider,
            );
          },
        ),
      ),
    );
  }
}
