import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/textfields/num_text_field.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_field_time.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/models/class_model.dart';

class HalaqahScreen extends ConsumerStatefulWidget {

  const HalaqahScreen({super.key,});

  @override
  ConsumerState<HalaqahScreen> createState() => _HalaqahScreenState();
}

class _HalaqahScreenState extends ConsumerState<HalaqahScreen> {
  bool _initialized = false;
  TextEditingController name = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController loc = TextEditingController();
  TextEditingController cap = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  List<int> days = [];
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> weekDaysData = [
    {
      'day': "weekdays.1".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.2".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.3".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.4".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.5".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.6".tr(),
      'selected': false,
    },
    {
      'day': "weekdays.7".tr(),
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

    final asyncHalaqah = ref.watch(classDetailsProvider);

    void updateHalaqah() async {

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

      await ref.read(classDetailsProvider.notifier).updateHalaqah(
        name: name.text,
        description: des.text,
        roomNumber: loc.text,
        scheduleDays: days,
        startTime: startTime.text,
        endTime: endTime.text,
      );

      final state = ref.watch(classDetailsProvider);

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"error".tr()}')),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"updated_success".tr()}')),
        );
      }
      setState(() {
        ability = true;
      });
    }


    return Scaffold(
      appBar: AppbarExtraButton(
        text: "class_details".tr(),
        addBackButton: true,
        icon: Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
        onPress: () async {
          final confirm = await showConfirmationDialog(
            context: context,
            title: "delete_class_title".tr(),
            message: "delete_class_message".tr(),
            cancelText: "cancel".tr(),
            confirmText: "confirm".tr(),
            confirmColor: Colors.red,
          );
          print("");
          if (confirm){
            ref.watch(classesProvider.notifier).deleteClass();
            Navigator.of(context).pop();
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: asyncHalaqah.when(
            data: (halaqa) {
              if (!_initialized && halaqa != null) {
                _initialized = true;

                name.text = halaqa.name;
                des.text = halaqa.description;
                loc.text = halaqa.location;
                startTime.text = halaqa.startTime;
                endTime.text = halaqa.endTime;
                // days = halaqa.days.cast<int>();
                halaqa.days.forEach((day){
                  weekDaysData[int.parse(day)-1]['selected'] = true;
                  days.add(int.parse(day));
                });
              }
              return SingleChildScrollView(
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
                          title:  "des".tr()
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
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge,
                          ),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weekDaysData.length,
                              itemBuilder: (context, index) =>
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: VerseNumber(
                                        onPressed: () {
                                          setState(() {
                                            weekDaysData[index]["selected"] =
                                            !weekDaysData[index]["selected"];
                                            if (weekDaysData[index]["selected"]){
                                              days.add(index+1);
                                            }else{
                                              days.remove(index+1);
                                            }
                                          });
                                        },
                                        num: weekDaysData[index]['day'],
                                        selected: weekDaysData[index]["selected"]
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
                          TextFieldTime(textController: startTime,
                            title: "start_time".tr(),),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Icon(

                                Icons.arrow_right_alt_outlined
                            ),
                          ),
                          TextFieldTime(textController: endTime,
                            title: "end_time".tr(),),
                        ],
                      ),
                      ElevatedDark(
                        onPressed: () {
                          updateHalaqah();
                        },
                        text: "${"update".tr()} ${"classes".tr()}",
                        ability: ability,
                      ),
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .padding
                            .bottom,
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (e, stack) {
              if (e is UnauthorizedException) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomErrorWidget(
                providerToInvalidate: classDetailsProvider,
              );
            },
            loading: () => LoadingWidget(),
        ),
      ),
    );
  }
}
