import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:halqati/provider/api_service_provider.dart';

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

  Future<void> _submitLogin(BuildContext context) async {
    // Navigator.of(context).pushNamed('/home_app_bar');
    // return
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // final tokenService = TokenStorage();
    final String phone = _phoneController.text;
    final String pin = _passwordController.text;

    final apiService = ref.read(apiServiceProvider);
    final userData = await apiService.login(phone, pin);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (userData != null) {
      await ref.read(tokenProvider.notifier).login(userData['token']);
      // 🎉 Success!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
      // print("Login Screen: ");

      if (userData['role'] == 'teacher'){
        final Teacher teacher = Teacher.fromJson(userData['user']);
        ref.read(teacherProvider.notifier).setTeacher(teacher);
        Navigator.of(context).pushNamed("/home_app_bar");
      }else{
        final Student student = Student.fromJson(userData['user']);
        ref.read(studentProvider.notifier).setStudent(student);
        Navigator.of(context).pushNamed("/dashboard_app_bar");
      }
      // Navigator.of(context).pushNamed("/root_screen");
    } else {
      // 🛑 Failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials or network.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final settings = ModalRoute.of(context)!.settings;
    // final args = settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar:  AppbarWithLogo(
        text: "user_type_selection.login".tr(),
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
                      "login_screen.welcome_back".tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  TextPhone(hintText: "login_screen.hint_phone".tr(),textController: _phoneController,title: "login_screen.phone".tr(),),
                  TextFieldPassword(hintText: "login_screen.hint_password".tr(),textController: _passwordController, title: "login_screen.password".tr(),),
                  FullWidthButton(
                    onPressed: _submitLogin,
                      text: _isLoading
                      ? "login_screen.logging_in".tr() // Show different text
                      :"login_screen.login_button".tr(),
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
