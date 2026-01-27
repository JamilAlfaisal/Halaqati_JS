import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:halqati/widgets/buttons/elevated_dark.dart';
// import 'package:halqati/widgets/buttons/elevated_light.dart';
import 'package:halqati/widgets/buttons/full_width_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              FullWidthButton(
                onPressed: (context){
                Navigator.of(context).pushNamed(
                  '/root_screen',
                  // arguments: {
                  //   'userType': 'student', // The parameter key
                  // },
                );
              }, text: "user_type_selection.login".tr(),),
              // FullWidthButton(
              //   onPressed: (context){
              //     Navigator.of(context).pushNamed(
              //       '/login_screen',
              //     );
              //   }, text: "login_screen",),
            ],
          ),
        ),
      ),
    );
  }
}
