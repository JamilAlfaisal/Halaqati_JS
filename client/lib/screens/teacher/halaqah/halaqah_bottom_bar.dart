import 'package:flutter/material.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/screens/teacher/halaqah/student_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/screens/teacher/halaqah/event_screens/events_screen.dart';
import 'package:halqati/screens/teacher/halaqah/halaqah_screen.dart';
import 'package:halqati/screens/teacher/halaqah/attendance_screens/attendance_screen.dart';

class HalaqahBottomBar extends StatefulWidget {
  const HalaqahBottomBar({super.key});

  @override
  State<HalaqahBottomBar> createState() => _HalaqahBottomBarState();
}

class _HalaqahBottomBarState extends State<HalaqahBottomBar> {
  int currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    final screen = [
      HalaqahScreen(),
      StudentScreen(),
      EventsScreen(),
      AttendanceScreen(),
    ];
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/muz1.png"),
              fit: BoxFit.fill,
            ),
          ),
        child: screen[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            label: "class".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "students".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "events".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: "attendance".tr(),
          ),
        ],
      ),
    );
  }
}
