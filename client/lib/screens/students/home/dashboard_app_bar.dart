import 'package:flutter/material.dart';
import 'package:halqati/screens/students/home/dashboard_screen.dart';
import 'package:halqati/screens/students/home/profile_screen.dart';
import 'package:halqati/screens/students/home/events_screen.dart';
import 'package:halqati/screens/common_screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardAppBar extends StatefulWidget {
  const DashboardAppBar({super.key});

  @override
  State<DashboardAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<DashboardAppBar> {
  int currentIndex = 0;
  final screen = const [
    DashboardScreen(),
    EventsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.home),
            label: "student_app_bar.bar.dashboard".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "student_app_bar.bar.events".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "student_app_bar.profile.profile".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "student_app_bar.bar.settings".tr(),
          ),
        ],
      ),
    );
  }
}
