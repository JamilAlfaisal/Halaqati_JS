import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/widgets/cards/personal_user_details.dart';
import 'package:halqati/widgets/profile/student_profile_left.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncStudent = ref.watch(studentDashboard);
    final List<int> pages = List.generate(30, (index) => index + 1);

    String displayDate(String? date){
      if (date == "" || date == null){
        return "00-00-00";
      }
      return date.split("T")[0];
    }



    return Scaffold(
      appBar: AppbarWithLogo(
        text: "profile_screen.profile".tr(),
        onLogout: (){
          ref.read(tokenProvider.notifier).logout();
        },
      ),
      body: asyncStudent.when(
        data: (data){
          List<String> memorizedJuz = data?.memorizedJuz??[];
          print(memorizedJuz);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentDashboard);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      SizedBox(height: 20,),
                      StudentProfileLeft(
                        student: data??Student(
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
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "student_profile_screen.eamil_details".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 5,),
                      PersonalUserDetails(
                        phone: data?.phone??"teacher_profile.no_phoneno_phone".tr(),
                        email: data?.email??"teacher_profile.no_email".tr(),
                        dob: data!.dob,
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "student_profile_screen.memorized_pages".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 10,),
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
                                onPressed: (){},
                                num: pages[index],
                                selected: memorizedJuz.contains(pages[index].toString()),
                              );
                            }
                        ),
                      )
                    ],
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
                    onPressed: () => ref.invalidate(studentDashboard),
                    child: Text("home_screen.retry".tr()),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator())
      ),
    );
  }
}
