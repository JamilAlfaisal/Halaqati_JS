import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/widgets/profile/student_profile_left.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStudent = ref.watch(studentDashboard);
    final Student? student = asyncStudent.value;
    final isLoading = asyncStudent.isLoading;
    final List<int> pages = List.generate(604, (index) => index + 1);
    print(student?.dateOfBirth);

    String displayDate(String? date){
      if (date == "" || date == null){
        return "00-00-00";
      }
      return date.split("T")[0];
    }



    return Scaffold(
      appBar: AppbarWithLogo(text: "student_app_bar.profile.profile".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentProfileLeft(
              student: student??Student(),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "student_profile_screen.eamil_details".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    isLoading?"Loading...":
                    "${"student_profile_screen.email".tr()}: ${student?.email??"student_profile_screen.un_defined".tr()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    isLoading?"Loading...":
                    "${"student_profile_screen.phone".tr()}: ${student?.phone??"student_profile_screen.un_defined".tr()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    isLoading?"Loading...":
                    "${"student_profile_screen.dob".tr()}: ${displayDate(student?.dateOfBirth)}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "student_profile_screen.memorized_pages".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                    height: 300,
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
            )
          ],
        ),
      ),
    );
  }
}
