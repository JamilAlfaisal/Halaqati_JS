import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';

// 1. Change to ConsumerStatefulWidget
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

// 2. State class extends ConsumerState
class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    bool isSwitched = currentLocale.languageCode == 'en';
    return Scaffold(
      appBar: AppbarWithLogo(text: "setting".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 80,
                // padding: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("english".tr(), style: const TextStyle(fontSize: 16)),
                    Switch(
                      // inactiveTrackColor: Theme.of(context).primaryColor,
                      inactiveThumbColor: Theme.of(context).primaryColor,
                      value: isSwitched,
                      onChanged: (value) {
                          final newLocale = (currentLocale.languageCode == 'en')
                              ? const Locale('ar') // Switch to Arabic
                              : const Locale('en');
                          context.setLocale(newLocale);
                      },
                      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                         return Theme.of(context).primaryColor;
                      }),
                      // activeColor: Colors.green,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: (){
                  final snackBar = SnackBar(
                    content: Text('not_available'.tr()),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  // padding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("about_us".tr(), style: const TextStyle(fontSize: 16)),
                      Icon(Icons.info_outline_rounded)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final snackBar = SnackBar(
                    content: Text('not_available'.tr()),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("report_issues".tr(), style: const TextStyle(fontSize: 16)),
                      Icon(Icons.warning_amber),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (mounted) {
                    await AuthHelper.handleLogout(ref);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("logout".tr(), style: const TextStyle(fontSize: 16)),
                      Icon(Icons.logout),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}