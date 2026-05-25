import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/juz_data.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/cards/user_details.dart';
import 'package:halqati/widgets/chapter_toggle_widget.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
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
    final languageCode = context.locale.languageCode;
    final studentsAsync = ref.watch(studentsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final String studentId = ref.watch(selectedStudentIdProvider)??"0";

    late final studentPhoneNumber;
    return Scaffold(
      appBar: AppbarExtraButton(
        icon: Icon(Icons.person_remove_alt_1, color: Colors.red),
        text: halaqahName,
        onPress: () async {
          final confirm = await showConfirmationDialog(
            context: context,
            title: "remove_student".tr(),
            message: "remove_student_msg".tr(),
            cancelText: "cancel".tr(),
            confirmText: "confirm".tr(),
            confirmColor: Colors.red,
          );
          if(confirm){
            ref
                .read(studentsProvider.notifier)
                .removeStudent(studentPhoneNumber);
            Navigator.of(context).pop();
          }
        },
        addBackButton: true,
      ),
      body: studentsAsync.when(
          data: (students){
            final Student student = students!.firstWhere(
              (s) => s.id == studentId,
              orElse: () => Student.emptyStudent(),
            );
            List<String> memorizedJuz = student.memorizedJuz;
            studentPhoneNumber = student.phone;
            return  ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: [
                StudentProfileLeft(student: student,),
                SizedBox(height: 20,),
                Text(
                  "user_info".tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 10,),
                UserDetails(
                  email: student.email,
                  phone: student.phone,
                  dob: student.dob,
                ),
                SizedBox(height: 20,),
                Text(
                  "memorized_juz".tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 20,),
                Container(
                  height: MediaQuery.of(context).size.height*0.65,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: JuzData.juzNamesArabic.length,
                    itemBuilder: (context, index){
                      return ChapterToggleWidget(
                        chapterNumber: index + 1,
                        isMemorized: memorizedJuz.contains(pages[index].toString()),
                        title: languageCode == "en"?JuzData.juzNamesEnglish[index]:JuzData.juzNamesArabic[index],
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

            return CustomErrorWidget(
              providerToInvalidate: studentsProvider,
            );
          },
          loading: () => LoadingWidget()
      )
    );
  }
}
