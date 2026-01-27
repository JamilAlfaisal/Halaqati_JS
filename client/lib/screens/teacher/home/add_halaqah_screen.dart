import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/provider/teacher_providers/profile_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/textfields/num_text_field.dart';
import 'package:halqati/widgets/textfields/text_field_time.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';

class AddHalaqahScreen extends ConsumerStatefulWidget {
  const AddHalaqahScreen({super.key});

  @override
  ConsumerState<AddHalaqahScreen> createState() => _AddHalaqahScreenState();
}

class _AddHalaqahScreenState extends ConsumerState<AddHalaqahScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController loc = TextEditingController();
  TextEditingController cap = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  List<String> days = [];
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> weekDaysData = [
    {
      'day': 'add_halaqah_screen.Monday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Tuesday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Wednesday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Thursday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Friday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Saturday'.tr(),
      'selected': false,
    },
    {
      'day': 'add_halaqah_screen.Sunday'.tr(),
      'selected': false,
    },
  ];
  Map<String, String> enDays = {
    "الاثنين":"Monday",
    "الثلاثاء":"Tuesday",
    "الأربعاء":"Wednesday",
    "الخميس":"Thursday",
    "الجمعة":"Friday",
    "السبت":"Saturday",
    "الأحد":"Sunday"
  };
  bool ability = true;

  @override
  Widget build(BuildContext context) {
    // Example of how you would call this in your button's logic

    void handleCreateClassButton() async {
      setState(() {
        ability = false;
      });
      // 1. Retrieve the token (e.g., from your secure storage)
      // Assuming you have a way to securely retrieve the token
      if (!_formKey.currentState!.validate()) {
        setState(() {
          ability = true;
        });
        return;
      }

      if (days.isEmpty){
        setState(() {
          ability = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('add_halaqah_screen.select_days'.tr()))
        );
        return;
      }

      try{
        final success = await ref.read(classesProvider.notifier)
            .createClass(
          name: name.text,
          description: des.text,
          capacity: int.tryParse(cap.text)??20,
          roomNumber: loc.text,
          scheduleDays: days,
          scheduleTime: '${startTime.text}-${endTime.text}',
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('add_halaqah_screen.creating_halaqa_success'.tr())),
          );
          return;
        }
      } on ValidationException catch (e){
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } on NetworkException {
        // ✅ Handle network errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('add_halaqah_screen.network_error'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on UnauthorizedException {
        // ✅ Auth errors handled by RootScreen, but you can show a message
        if (mounted) {
          await AuthHelper.handleLogout(ref as Ref);
        }

        // RootScreen will automatically navigate to login
      } catch (e) {
        // ✅ Generic error
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("add_halaqah_screen.error_title".tr()),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } finally {
        // ✅ Always re-enable the button
        if (mounted) {
          setState(() {
            ability = true;
          });
        }
      }
    }
    // print(days);
    // print(weekDaysData[0]['day']);
    // print(enDays[weekDaysData[0]['day']]);
    return Scaffold(
      appBar: AppbarWithButton(
        text: "add_halaqah_screen.create".tr(),
        addBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                TextFieldNormal(
                  hintText: "add_halaqah_screen.enter_halaqa_name".tr(),
                  textController: name,
                  title: "add_halaqah_screen.halaqa_name".tr()
                ),
                TextArea(
                  textController: des,
                  title: "add_halaqah_screen.des".tr()
                ),
                TextFieldNormal(
                    hintText: "add_halaqah_screen.enter_location".tr(),
                    textController: loc,
                    title: "add_halaqah_screen.localtion".tr()
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "add_halaqah_screen.schedule".tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weekDaysData.length,
                        itemBuilder: (context, index)=>
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: VerseNumber(
                                onPressed: (){
                                  setState(() {
                                    weekDaysData[index]["selected"] = !weekDaysData[index]["selected"];
                                    if (weekDaysData[index]["selected"] && context.locale.languageCode == 'en'){
                                      days.add(weekDaysData[index]["day"]);
                                    }else if (weekDaysData[index]["selected"] && context.locale.languageCode == 'ar'){
                                      days.add(enDays[weekDaysData[index]["day"]]??"الاثنين");
                                    }else if (!weekDaysData[index]["selected"] && context.locale.languageCode == 'ar'){
                                      days.remove(enDays[weekDaysData[index]["day"]]??"الاثنين");
                                    }else{
                                      days.remove(weekDaysData[index]["day"]);
                                    }

                                  });
                                }, num: weekDaysData[index]['day'], selected: weekDaysData[index]["selected"]
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
                NumTextField(textController: cap, title: "add_halaqah_screen.capacity".tr(),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFieldTime(textController: startTime, title: "add_halaqah_screen.start_time".tr(),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Icon(

                        Icons.arrow_right_alt_outlined
                      ),
                    ),
                    TextFieldTime(textController: endTime, title: "add_halaqah_screen.end_time".tr(),),
                  ],
                ),
                ElevatedDark(
                  onPressed: (){
                    handleCreateClassButton();
                  },
                  text: "add_halaqah_screen.create_button".tr(),
                  ability: ability,
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
