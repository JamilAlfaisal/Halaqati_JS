import 'package:flutter/material.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/screens/teacher/halaqah/student_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/screens/teacher/halaqah/events_screen.dart';
import 'package:halqati/screens/teacher/halaqah/halaqah_screen.dart';

class HalaqahBottomBar extends StatefulWidget {
  const HalaqahBottomBar({super.key});

  @override
  State<HalaqahBottomBar> createState() => _HalaqahBottomBarState();
}

class _HalaqahBottomBarState extends State<HalaqahBottomBar> {
  int currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as HalaqaClass;
    final screen = [
      HalaqahScreen(),
      StudentScreen(),
      EventsScreen(),
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
            icon: Icon(Icons.sticky_note_2_outlined),
            label: "halaqah_bottom_bar.halaqah".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "halaqah_bottom_bar.students".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "halaqah_bottom_bar.events".tr(),
          ),
        ],
      ),
    );
  }
}
