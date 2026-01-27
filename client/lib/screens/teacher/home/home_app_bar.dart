import 'package:flutter/material.dart';
import 'package:halqati/screens/teacher/home/home_screen.dart';
import 'package:halqati/screens/teacher/home/profile_screen.dart';
import 'package:halqati/screens/common_screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  int currentIndex = 0;
  final screen = const [
    HomeScreen(),
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
            label: "home_app_bar.home".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "home_app_bar.profile".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "home_app_bar.settings".tr(),
          ),
        ],
      ),
    );
  }
}
