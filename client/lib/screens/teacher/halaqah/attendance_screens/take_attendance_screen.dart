import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/attendance_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/student_attendance_item.dart';
import 'package:halqati/widgets/loading_widget.dart';

class TakeAttendanceScreen extends ConsumerStatefulWidget {
  const TakeAttendanceScreen({super.key});

  @override
  ConsumerState<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends ConsumerState<TakeAttendanceScreen> {


  final List<int> selectedStudents = [];
  @override
  Widget build(BuildContext context) {
    final asyncStudents = ref.watch(studentsProvider);
    final studentNotifier = ref.read(attendanceProvider.notifier);
    final String className= ref.watch(selectedClassNameProvider)??"name";
    return Scaffold(
      appBar: AppbarWithButton(
        text: className,
        addBackButton: true,
      ),
      body: asyncStudents.when(
        data: (data){

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: data?.length??0,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 20,
                    right: 20,
                  ),
                  itemBuilder: (context, index){

                    return StudentAttendanceItem(
                      onChanged: (isSelected){
                        if (selectedStudents.contains(int.tryParse(data?[index].id??"0")??0)){
                          setState(() {
                            selectedStudents.remove(int.tryParse(data?[index].id??"0")??0);
                          });
                        }else{
                          setState(() {
                            selectedStudents.add(int.tryParse(data?[index].id??"0")??0);
                          });
                        }
                      },
                      isSelected: selectedStudents.contains(int.tryParse(data?[index].id??"0")??0),
                      studentName: data?[index].name??"name".tr(),
                      subtitle: "${data?[index].memorizedJuz.length??"0"}",
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await studentNotifier.takeAttendance(
                      studentIds: selectedStudents.toList(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("created_success".tr())),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${"error".tr()}: $e")),
                    );
                  }
                },
                child: Text("${"take".tr()} ${"attendance".tr()}"),
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
            providerToInvalidate: studentsProvider,
          );
        }
      )
    );
  }
}
