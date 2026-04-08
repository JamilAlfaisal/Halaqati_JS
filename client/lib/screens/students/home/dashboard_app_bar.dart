import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/student_states_model.dart';
import 'package:halqati/provider/student_providers/student_state_provider.dart';
import 'package:halqati/screens/students/home/dashboard_screen.dart';
import 'package:halqati/screens/students/home/profile_screen.dart';
import 'package:halqati/screens/students/home/events_screen.dart';
import 'package:halqati/screens/common_screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardAppBar extends ConsumerStatefulWidget {
  const DashboardAppBar({super.key});

  @override
  ConsumerState<DashboardAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends ConsumerState<DashboardAppBar> {
  int currentIndex = 0;
  final screen = const [
    DashboardScreen(),
    EventsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final StudentStats studentState = ref.watch(studentStatsProvider).value ?? StudentStats.emptyStats();
    final unreadAssignments = (studentState.totalAssignments - studentState.readAssignments);
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
            icon: Icon(Icons.class_),
            label: "classes".tr(),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              largeSize: 7,
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text("${unreadAssignments}"), // Replace '3' with your dynamic unread count variable
              child: const Icon(Icons.event),
            ),
            label: "assignments".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "profile".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "setting".tr(),
          ),
        ],
      ),
    );
  }
}
