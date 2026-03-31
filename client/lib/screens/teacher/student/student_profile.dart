import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_rermove_student.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/widgets/cards/user_details.dart';
import 'package:halqati/widgets/profile/student_profile_left.dart';


class StudentProfile extends ConsumerStatefulWidget {
  const StudentProfile({
    super.key
  });

  @override
  ConsumerState<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfile> {
  final List<int> pages = List.generate(30, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final String studentId = ref.watch(selectedStudentIdProvider)??"0";
    late final studentPhoneNumber;
    return Scaffold(
      appBar: AppbarRemoveStudent(
        text: halaqahName,
        onPress: (){
          ref.read(studentsProvider.notifier).removeStudent(studentPhoneNumber);
          Navigator.of(context).pop();
        },
        addBackButton: true,
      ),
      body: studentsAsync.when(
          data: (students){
            final Student student = students!.firstWhere(
              (s) => s.id == studentId,
              orElse: () => new Student(
                id: '',
                name: '',
                email: '',
                role: '',
                dob: DateTime(2017, 9, 7, 17, 30),
                createdAt: DateTime(2017, 9, 7, 17, 30),
                picProfile: '',
                phone: '',
                memorizedJuz: [],
                enrolledClasses: []
              ),
            );
            List<String> memorizedJuz = student.memorizedJuz;
            studentPhoneNumber = student.phone;
            return  ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [
                StudentProfileLeft(student: student,),
                SizedBox(height: 20,),
                Text(
                  "student_bottom_appbar.profile.profile".tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 10,),
                UserDetails(
                  email: student.email??"teacher_profile.no_email".tr(),
                  phone: student.phone??"student_bottom_appbar.profile.no_phone".tr(),
                  dob: student.dob,
                ),
                SizedBox(height: 20,),
                Text(
                  "student_bottom_appbar.profile.memorized_pages".tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 20,),
                SizedBox(
                  height: 200,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing:5,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index){
                      return PageNumber(
                        onPressed: (){
                          setState(() {
                            if (memorizedJuz.contains(pages[index].toString())){
                              memorizedJuz.remove(pages[index].toString());
                            }else{
                              memorizedJuz.add(pages[index].toString());
                            }
                          });
                          ref.watch(studentsProvider.notifier).updateMemorizedJuz(
                            studentId: student.id,
                            newJuzList: memorizedJuz
                          );
                        },
                        num: pages[index],
                        selected: memorizedJuz.contains(pages[index].toString()),
                      );
                    }
                  ),
                ),
              ],
            );
          },
          error: (e, stack) {

            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error loading halaqat",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(studentsProvider),
                    child: Text("home_screen.retry".tr()),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator())
      )
    );
  }
}
