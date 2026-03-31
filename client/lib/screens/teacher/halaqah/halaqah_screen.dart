import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/widgets/appbar/appbar_delete_button.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
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
      'day': 'add_halaqah_screen.Sunday'.tr(),
      'selected': false,
    },
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

    print(asyncHalaqah.error);

    void updateHalaqah() async {

      await ref.read(classDetailsProvider.notifier).updateHalaqah(
        name: name.text,
        description: des.text,
        roomNumber: loc.text,
        scheduleDays: days,
        startTime: startTime.text,
        endTime: endTime.text,
      );

      final state = ref.read(classDetailsProvider);

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"error".tr()}: ${state.error}')),
        );
      }
    }


    return Scaffold(
      appBar: AppbarDeleteButton(
        text: "class_details".tr(),
        addBackButton: true,
        onPress: (){
          ref.watch(classesProvider.notifier).deleteClass();
          Navigator.of(context).pop();
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


                halaqa.days.forEach((day){
                  weekDaysData[int.parse(day)-1]['selected'] = true;
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading halaqat",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // ✅ Add retry button for errors
                    ElevatedButton(
                      onPressed: () => ref.invalidate(classesProvider),
                      child: Text("home_screen.retry".tr()),
                    ),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
