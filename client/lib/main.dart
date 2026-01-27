import 'package:flutter/material.dart';
import 'package:halqati/config/app_theme.dart';
import 'package:halqati/screens/common_screens/login_screen.dart';
import 'package:halqati/test/testing_widgets.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/screens/common_screens/register_screen.dart';
import 'package:halqati/screens/teacher/home/home_app_bar.dart';
import 'package:halqati/screens/teacher/home/add_halaqah_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/screens/teacher/halaqah/halaqah_bottom_bar.dart';
import 'package:halqati/screens/students/home/dashboard_app_bar.dart';
import 'package:halqati/screens/common_screens/root_screen.dart';
import 'package:halqati/screens/teacher/student/student_bottom_appbar.dart';
import 'package:halqati/screens/teacher/student/add_assignment_screen.dart';
import 'package:halqati/screens/students/halaqa_details_screen.dart';
import 'package:halqati/screens/students/event_details_screen.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        child: const MyApp(),
      )
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: const Locale('ar'),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialRoute: '/root_screen',
      navigatorObservers: [routeObserver],
      routes: {
        // '/': (context) => const RootScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/login_screen':(context) => const LoginScreen(),
        '/home_app_bar':(context) => const HomeAppBar(),
        '/add_halaqah_screen':(context) => const AddHalaqahScreen(),
        '/halaqah_bottom_bar':(context) => const HalaqahBottomBar(),
        '/dashboard_app_bar': (context) => const DashboardAppBar(),
        '/student_bottom_appbar':(context) => const StudentBottomAppbar(),
        '/add_assignment_screen':(context) => const AddAssignmentScreen(),
        '/halaqa_details_screen':(context) => const HalaqaDetailsScreen(),
        '/event_details_screen':(context) => const EventDetailsScreen(),
        '/root_screen': (context) => const RootScreen(),
      },
    );
  }
}

// ElevatedDark(onPressed: (){
// final currentLocale = context.locale;
// final newLocale = (currentLocale.languageCode == 'en')
// ? const Locale('ar') // Switch to Arabic
//     : const Locale('en');
// context.setLocale(newLocale);
// }, text: "change language",),