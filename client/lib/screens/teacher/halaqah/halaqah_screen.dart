import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/buttons/verse_number.dart';
import 'package:halqati/widgets/textfields/num_text_field.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_field_time.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/models/halaqa_class.dart';

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
    // final asyncHalaqah = ref.watch(classDetailsProvider(widget.id));
    final asyncHalaqah = ref.watch(classDetailsProvider);

    print(asyncHalaqah.error);

    void updateHalaqah() async {
      // 1. Trigger the update through the notifier
      // Use ref.read here because this is inside a function/callback
      await ref.read(classDetailsProvider.notifier).updateHalaqah(
        name: name.text,
        description: des.text,
        capacity: int.tryParse(cap.text) ?? 20,
        roomNumber: loc.text,
        scheduleDays: days, // Your list of strings
        scheduleTime: '${startTime.text}-${endTime.text}',
      );

      // 2. Handle the result
      final state = ref.read(classDetailsProvider);

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${state.error}')),
        );
      }
    }


    return Scaffold(
      appBar: AppbarWithButton(
        text: "halaqah_screen.halaqah.details".tr(),
        addBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: asyncHalaqah.when(
            data: (halaqa) {
              if (!_initialized && halaqa != null) {
                _initialized = true;
                final List<String> start_end_time =
                    halaqa.time != null?halaqa.time!.split('-'):["", ""];

                name.text = halaqa.name ?? '';
                des.text = halaqa.description ?? '';
                loc.text = halaqa.roomNumber ?? '';
                cap.text = halaqa.capacity.toString();
                startTime.text = start_end_time[0];
                endTime.text = start_end_time[1];

                if (halaqa.days != null){
                  if(Localizations.localeOf(context).languageCode == 'en'){
                    weekDaysData.forEach((day){
                      print(day);
                      if(halaqa.days!.contains(day['day'])){
                        day['selected'] = true;
                      }
                    });
                  }else{
                    weekDaysData.forEach((day){
                      if(halaqa.days!.contains(enDays[day['day']])){
                        day['selected'] = true;
                      }
                    });
                  }
                }
              }
              return SingleChildScrollView(
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
                                            if (weekDaysData[index]["selected"] &&
                                                context.locale.languageCode == 'en') {
                                              days.add(weekDaysData[index]["day"]);
                                            } else
                                            if (weekDaysData[index]["selected"] &&
                                                context.locale.languageCode == 'ar') {
                                              days.add(
                                                  enDays[weekDaysData[index]["day"]] ??
                                                      "الاثنين");
                                            } else
                                            if (!weekDaysData[index]["selected"] &&
                                                context.locale.languageCode == 'ar') {
                                              days.remove(
                                                  enDays[weekDaysData[index]["day"]] ??
                                                      "الاثنين");
                                            } else {
                                              days.remove(weekDaysData[index]["day"]);
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
                      NumTextField(textController: cap,
                        title: "add_halaqah_screen.capacity".tr(),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFieldTime(textController: startTime,
                            title: "add_halaqah_screen.start_time".tr(),),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Icon(
                
                                Icons.arrow_right_alt_outlined
                            ),
                          ),
                          TextFieldTime(textController: endTime,
                            title: "add_halaqah_screen.end_time".tr(),),
                        ],
                      ),
                      ElevatedDark(
                        onPressed: () {
                          updateHalaqah();
                        },
                        text: "add_halaqah_screen.update".tr(),
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
