import 'package:flutter/material.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/screens/teacher/halaqah/student_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/screens/teacher/student/assignment_screen.dart';
import 'package:halqati/screens/teacher/student/student_profile.dart';

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
            label: "student_bottom_appbar.student_profile".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "student_bottom_appbar.assignments".tr(),
          ),
        ],
      ),
    );
  }
}
