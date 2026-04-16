import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/country_code_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/textfields/text_phone.dart';
import 'package:halqati/widgets/textfields/text_field_password.dart';
import 'package:halqati/widgets/buttons/full_width_button.dart';
import 'package:halqati/provider/teacher_providers/student_provider.dart';
import 'package:halqati/provider/teacher_providers/teacher_provider.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/provider/services_providers/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Inside the _LoginScreenState class
  bool _isLoading = false; // State variable for loading indicator
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitLogin(BuildContext context, ref) async {
    final String phoneCountryCode = ref.watch(countryCodeProvider)??"+961";
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // final tokenService = TokenStorage();
    final String phone = phoneCountryCode + _phoneController.text;
    final String pin = _passwordController.text;

    final apiService = ref.read(authApiProvider);
    final userData = await apiService.login(phone, pin);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (userData != null) {
      await ref.read(tokenProvider.notifier).login(userData['token']);
      await syncDeviceToken(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        ref.read(authApiProvider).updateFcmToken(newToken);
      });

      if (userData['user']['role'] == 'teacher'){
        final Teacher teacher = Teacher.fromJson(userData['user']);
        ref.read(teacherProvider.notifier).setTeacher(teacher);
        Navigator.of(context).pushNamed("/home_app_bar");
      }else if(userData['user']['role'] == 'student'){
        final Student student = Student.fromJson(userData['user']);
        ref.read(studentProvider.notifier).setStudent(student);
        Navigator.of(context).pushNamed("/dashboard_app_bar");
      }
    } else {
      // 🛑 Failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials or network.')),
      );
    }
    ref.read(countryCodeProvider.notifier).clear();
  }

  Future<void> syncDeviceToken(WidgetRef ref) async {
    final token = await ref.read(tokenProvider).value ?? "";
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await messaging.getToken();

      if (fcmToken != null) {
        // 3. Send this to your Express.js backend
        // POST /users/device-token { token: "..." }
        await ref.read(authApiProvider).updateFcmToken(token: token, fcmToken: fcmToken);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final settings = ModalRoute.of(context)!.settings;
    // final args = settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar:  AppbarWithLogo(
        text: "login".tr(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Text(
                      "welcome_back".tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  TextPhone(
                    hintText: "enter_phone".tr(),
                    textController: _phoneController,
                    title: "phone".tr(),
                  ),
                  TextFieldPassword(hintText: "enter_password".tr(),textController: _passwordController, title: "password".tr(),),
                  FullWidthButton(
                    onPressed: _submitLogin,
                      text: _isLoading
                      ? "loading".tr() // Show different text
                      :"login".tr(),
                    isActive: !_isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
