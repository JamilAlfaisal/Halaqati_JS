import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/teacher_providers/profile_provider.dart';
import 'package:halqati/screens/common_screens/login_screen.dart';
import 'package:halqati/models/auth_user.dart';
import 'package:halqati/screens/teacher/home/home_app_bar.dart';
import 'package:halqati/screens/students/home/dashboard_app_bar.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';


class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<AuthUser?>>(
      authProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            if (error is UnauthorizedException) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session expired. Please login again.'.tr()),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        );
      },
    );

    return authState.when(
      data: (user) {
        // print("being triggered root screen");
        if (user == null) return const LoginScreen();
        return switch (user) {
          AuthTeacher() => HomeAppBar(),
          AuthStudent() => DashboardAppBar(),
        };
      },
      loading: () { return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/muz1.png"),
              fit: BoxFit.fill,
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Image.asset("assets/images/alhamidi_logo.png"),
                    Text(
                      'app_name'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      );

      },
      error: (err, stack) {
        // print('Auth error in RootScreen: $err');
        return const LoginScreen();
      },
    );
  }
}
