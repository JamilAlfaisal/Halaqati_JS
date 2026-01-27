import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/buttons/elevated_light.dart';
import 'package:halqati/widgets/buttons/text_button_light.dart';
import 'package:halqati/widgets/buttons/delete_button.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
import 'package:halqati/widgets/buttons/filter_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/buttons/full_width_button.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_field_password.dart';
import 'package:halqati/widgets/textfields/text_field_date.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_search.dart';
import 'package:halqati/widgets/textfields/text_phone.dart';
import 'package:halqati/widgets/lists/halaqat_list.dart';
import 'package:halqati/widgets/lists/student_list.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';
import 'package:halqati/widgets/lists/events_list.dart';
import 'package:halqati/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/test/test_widget_a.dart';
import 'package:halqati/test/test_widget_b.dart';


class TestingWidgets extends ConsumerWidget {
  const TestingWidgets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _textController = TextEditingController();
    final tokenAsyncValue = ref.watch(tokenProvider);
    final apiService = ref.read(apiServiceProvider);
    return Scaffold(
      // appBar:  AppbarWithLogo(
      //   text: 'Test screen',
      // ),
      appBar: AppbarWithButton(
        text: "Test",
        addBackButton: false,
      ),
      floatingActionButton: FloatingButtonIcon(onPressed: (){
        Navigator.pushNamed(context, '/register_screen');
      }, text:'add student'),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        children: [
          TestWidgetA(),
          TestWidgetB(),
          // ElevatedDark(onPressed: (){print("Teacher");}, text: "Create Teacher Account",),
          // ElevatedLight(onPressed: (){print("Student");}, text: "Create Student Account",),
          // TextButtonLight(onPressed: (){print("TextButton");}, text: "Press Text Button",),
          // DeleteButton(onPressed: (){print("TextButton");}),
          // VerseNumber(onPressed: (){print('verse button');}, num: 100,selected: true,),
          // VerseNumber(onPressed: (){print('verse button');}, num: 1,selected: false,),
          // FilterButton(onPressed: (){print('filter button');}, text: 'all'),
          // FullWidthButton(onPressed: (){print('Full Width Button');}, text: 'Sign Up'),
          // TextFieldNormal(hintText: "Your Email",textController: _textController,title: "Enter your email",),
          // TextFieldPassword(hintText: "Your Password",textController: _textController,title: "Enter your password",),
          // TextFieldDate(hintText: "Select Date",textController: _textController,title: "Event Date",),
          // TextArea(textController: _textController,title: "Event Description",),
          // TextFieldSearch(hintText: "Search using student ID #",textController: _textController),
          // HalaqatList(title: "Halaqet Alhamidi", studentNumber: 12,onTap: (){print("Nav to halaqat");}),
          // StudentList(name: "Jamil Alfaisal", totalPagesMemorized: 200, onTap: (){print("Nav to student");},),
          // AssignmentList(title: "Surah AL-Baqqara",dueDate: "2024-01-15", onPressed: (){print("Delete");},),
          // EventsList(title: "Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice",
          //   date: "2024-07-20",
          //   description: 'review surah Al-Baqarah',
          //   onTap: (){print('Nav to events page');},
          // ),
          // EventsList(title: "Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice Quran Practice",
          //   date: "2024-07-20",
          //   description: 'review surah Al-Baqarah',
          // ),
          // ElevatedDark(onPressed: (){
          //   final currentLocale = context.locale;
          //   final newLocale = (currentLocale.languageCode == 'en')
          //       ? const Locale('ar') // Switch to Arabic
          //       : const Locale('en');
          //   context.setLocale(newLocale);
          // }, text: "change language",),
          // TextPhone(hintText: "Your Email",textController: _textController,title: "Enter your email",),
          // ElevatedDark(
          //   onPressed: ()async{
          //     print(tokenAsyncValue.value);
          //     if(tokenAsyncValue.value == null){
          //       return;
          //     }
          //     final List<Student>? studentsList = await apiService.getStudentsByClass(tokenAsyncValue.value!, 0);
          //     print(studentsList != null?studentsList[0].name:null);
          // }, text: "Test API")
        ],
      ),
    );
  }
}
