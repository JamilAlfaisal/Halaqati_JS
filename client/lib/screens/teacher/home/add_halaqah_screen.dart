import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
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
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  List<int> days = [];
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> weekDaysData = [
    {
      'day': 'weekdays.1'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.2'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.3'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.4'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.5'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.6'.tr(),
      'selected': false,
    },
    {
      'day': 'weekdays.7'.tr(),
      'selected': false,
    },
  ];

  final List<Map<int, String>> daysObject = [
    {1: "weekdays.1".tr()},
    {2: "weekdays.2".tr()},
    {3: "weekdays.3".tr()},
    {4: "weekdays.4".tr()},
    {5: "weekdays.5".tr()},
    {6: "weekdays.6".tr()},
    {7: "weekdays.7".tr()},
  ];

  bool ability = true;

  @override
  Widget build(BuildContext context) {
    void handleCreateClassButton() async {
      setState(() {
        ability = false;
      });
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
          SnackBar(content: Text('select_days'.tr()))
        );
        return;
      }

      try{
        await ref.read(classesProvider.notifier)
            .createClass(
              name: name.text,
              description: des.text,
              roomNumber: loc.text,
              scheduleDays: days,
              startTime: startTime.text,
              endTime: endTime.text,
            );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('created_success'.tr())),
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
              content: Text('error'.tr()),
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
              title: Text("error".tr()),
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
    return Scaffold(
      appBar: AppbarWithButton(
        text: "create_class".tr(),
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
                  hintText: "${"enter".tr()} ${"class_name".tr()}",
                  textController: name,
                  title: "class_name".tr()
                ),
                TextArea(
                  textController: des,
                  title: "des".tr()
                ),
                TextFieldNormal(
                    hintText: "${"enter".tr()} ${"location".tr()}",
                    textController: loc,
                    title: "location".tr()
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "schedule".tr(),
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
                                  if (weekDaysData[index]["selected"]){
                                      days.add(index+1);
                                  }else{
                                    days.remove(index+1);
                                  }
                                });
                              }, num: weekDaysData[index]['day'], selected: weekDaysData[index]["selected"]
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFieldTime(textController: startTime, title: "start_time".tr(),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Icon(

                        Icons.arrow_right_alt_outlined
                      ),
                    ),
                    TextFieldTime(textController: endTime, title: "end_time".tr(),),
                  ],
                ),
                ElevatedDark(
                  onPressed: (){
                    handleCreateClassButton();
                  },
                  text: "create_class".tr(),
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


