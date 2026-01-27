import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
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
  final List<int> pages = List.generate(604, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final int ?studentId = ref.watch(selectedStudentIdProvider)??0;

    return Scaffold(
      appBar: AppbarWithButton(
        text: "student_bottom_appbar.student_profile".tr(),
        addBackButton: true,
      ),
      body: studentsAsync.when(
          data: (students){

            final Student student = students!.firstWhere(
                  (s) => s.id == studentId,
              orElse: () => new Student(), // Returns null if no match is found
            );

            return  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
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
                    dob: student.dateOfBirth,
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "student_bottom_appbar.profile.memorized_pages".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(
                    height: 250,
                    child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pages.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,       // Number of columns (e.g., 4 page numbers per row)
                          crossAxisSpacing: 10,    // Horizontal space between items
                          mainAxisSpacing: 10,     // Vertical space between items
                          childAspectRatio: 1,     // Makes the items square
                        ),
                        itemBuilder: (context, index){
                          return PageNumber(
                              onPressed: (){},
                              num: pages[index],
                              selected: false
                          );
                        }
                    ),
                  ),
                ],
              ),
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
