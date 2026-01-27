import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/models/student.dart';

class StudentProfileLeft extends StatelessWidget {
  final Student student;
  const StudentProfileLeft({
    super.key,
    required this.student
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
                student.name??"student_bottom_appbar.profile.no_name".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "ID: #${student.id.toString()}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                "${"student_bottom_appbar.profile.pages".tr()}: ${student.memorizedPages?.length??0}/604",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          )
        ],
      ),
    );
  }
}
