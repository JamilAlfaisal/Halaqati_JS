import 'package:flutter/material.dart';
import 'package:halqati/models/teacher.dart';
import 'package:easy_localization/easy_localization.dart';

class TeacherProfile extends StatelessWidget {
  final Teacher? teacher;
  const TeacherProfile({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
        ],
      ),
      child: Row(
        spacing: 10,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/profile.png',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher?.name??"teacher_profile.no_name".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "ID: #${teacher?.id.toString()??"teacher_profile.no_name".tr()}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          )
        ],
      ),
    );
  }
}
