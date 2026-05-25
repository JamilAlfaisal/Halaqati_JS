import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/screens/teacher/student/assignment_screens/assignment_screen.dart';
import 'package:halqati/screens/teacher/student/student_profile.dart';
import 'package:halqati/screens/teacher/student/grades_screens/grades.dart';

class StudentBottomAppbar extends StatefulWidget {
  const StudentBottomAppbar({super.key});

  @override
  State<StudentBottomAppbar> createState() => _StudentBottomAppbarState();
}

class _StudentBottomAppbarState extends State<StudentBottomAppbar> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as HalaqaClass;
    final screen = [
      StudentProfile(),
      AssignmentScreen(),
      Grades(),
    ];
    return Scaffold(
      body: screen[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "student".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "assignments".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: "grades".tr(),
          ),
        ],
      ),
    );
  }
}
