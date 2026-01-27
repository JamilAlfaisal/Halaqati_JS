import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/teacher_providers/teacher_provider.dart';
import 'package:halqati/widgets/profile/teacher_profile.dart';
import 'package:intl/intl.dart';
import 'package:halqati/widgets/cards/user_details.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

String getDOB(String ?date){

  if(date == null){
    return "teacher_profile.no_DOB".tr();
  }else{
    return date.split('T')[0];
  }
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Teacher ?teacher = ref.watch(teacherProvider);
  late final halaqatDetails = ref.watch(teacherStatsProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWithLogo(text: "profile_screen.profile".tr()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeacherProfile(teacher: teacher),
              SizedBox(height: 20,),
              Text(
                "teacher_profile.user_details".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10,),
              UserDetails(
                phone: teacher?.phone??"teacher_profile.no_phoneno_phone".tr(),
                email: teacher?.email??"teacher_profile.no_email".tr(),
                dob: teacher?.dateOfBirth
              ),
              SizedBox(height: 20,),
              Text(
                "teacher_profile.halaqat_details".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10,),
              Center(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 40,
                  runSpacing: 40,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Text(
                          //   "teacher_profile.halaqat_number".tr(),
                          //   style: Theme.of(context).textTheme.bodyMedium,
                          // ),
                          Icon(Icons.co_present_outlined),
                          Text(
                            "${halaqatDetails['classCount'].toString()} ${"teacher_profile.class".tr()}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Text(
                          //   "teacher_profile.student_number".tr(),
                          //   style: Theme.of(context).textTheme.bodyLarge,
                          // ),
                          Icon(Icons.school_outlined),
                          Text(
                            "${halaqatDetails['studentCount'].toString()} ${"teacher_profile.student".tr()}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
