import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/widgets/cards/personal_user_details.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
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



    return Scaffold(
      appBar: AppbarWithLogo(
        text: "profile".tr(),
        onLogout: () async {
          await AuthHelper.handleLogout(ref);
        },
      ),
      body: asyncStudent.when(
        data: (data){
          List<String> memorizedJuz = data?.memorizedJuz??[];

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
                        student: data??Student.emptyStudent()
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "user_info".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 5,),
                      PersonalUserDetails(
                        phone: data?.phone??"undefined".tr(),
                        email: data?.email??"undefined".tr(),
                        dob: data!.dob,
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "memorized_juz".tr(),
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

            return CustomErrorWidget(
              providerToInvalidate: studentDashboard,
            );
          },
          loading: () => LoadingWidget()
      ),
    );
  }
}
