import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/teacher_providers/attendance_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/lists/student_attendance_item.dart';

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
    final asyncStudents = ref.watch(studentsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
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
                Expanded(
                  child: ListView.builder(
                    itemCount: asyncStudents?.length??0,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 20,
                      right: 20,
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
                        const SnackBar(content: Text("Attendance updated successfully")),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Update Attendance"),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom+20,
                )
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, stack) {
            print("error in the event screen: ${e}");
            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error loading events",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      ref.invalidate(attendanceProvider);
                      ref.invalidate(attendanceDetailsProvider);
                      await ref.refresh(attendanceDetailsProvider.future);
                    },
                    child: Text("home_screen.retry".tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
