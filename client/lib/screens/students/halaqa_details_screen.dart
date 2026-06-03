import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/provider/student_providers/student_classes_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/cards/halaqah_info_card.dart';
import 'package:halqati/widgets/cards/study_time_card.dart';
import 'package:halqati/widgets/cards/teacher_details_card.dart';
import 'package:halqati/widgets/lists/student_info_list.dart';

class HalaqaDetailsScreen extends ConsumerWidget {
  const HalaqaDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass =
    ref.watch(studentClassesProvider.notifier).getSelectedClass();

    final List<Map<int, String>> daysObject = [
      {1: "weekdays.1".tr()},
      {2: "weekdays.2".tr()},
      {3: "weekdays.3".tr()},
      {4: "weekdays.4".tr()},
      {5: "weekdays.5".tr()},
      {6: "weekdays.6".tr()},
      {7: "weekdays.7".tr()},
    ];

    if (selectedClass == null) {
      return Scaffold(
        appBar: AppbarWithButton(
          text: 'class_details'.tr(),
          addBackButton: true,
        ),
        body: Center(
          child: Text(
            'error'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final days = selectedClass.days;

    return Scaffold(
      appBar: AppbarWithButton(
        text: 'class_details'.tr(),
        addBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [
          /// 🔹 Halaqah Info
          HalaqahInfoCard(
            description:
            selectedClass.description,
            name: selectedClass.name,
          ),

          const SizedBox(height: 20),

          Text(
            "class_details".tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 5),

          /// 🔹 Study Time
          StudyTimeCard(
            location:
            selectedClass.location,
            hours:
            "${selectedClass.startTime} - ${selectedClass.endTime}",
          ),

          const SizedBox(height: 10),

          /// 🔹 Weekly Schedule
          Text(
            'schedule'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: days.isNotEmpty
                ? days.map((day) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                child: Text(
                  daysObject[(int.tryParse(day)??1)-1][int.tryParse(day)]??"",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList()
                : [
              Container(
                padding: const EdgeInsets.all(8),
                child: Text("not_defined".tr()),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            "${"students".tr()}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Container(
            height: MediaQuery.of(context).size.height*0.65,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: selectedClass.studyIn.length,
              itemBuilder: (context, index){
                return StudentInfoList(
                  name: selectedClass.studyIn[index].student.name,
                  chaptersMemorized: selectedClass.studyIn[index].student.memorizedJuz.length,
                  cumulativeGpa: double.parse(selectedClass.studyIn[index].cumulativeGrade),
                  phone: selectedClass.studyIn[index].student.phone,
                  totalPoints: selectedClass.studyIn[index].totalWeightPoints,
                  studentId: selectedClass.studyIn[index].student.id,
                  profilePicUrl: selectedClass.studyIn[index].student.picProfile,
                );
              }
            ),
          ),

          /// 🔹 Teacher Details
          const SizedBox(height: 20),
          Text(
            "${"teacher".tr()}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 10),

          TeacherDetailsCard(
            name: selectedClass.teacher.name,
            email: selectedClass.teacher.email,
            phone: selectedClass.teacher.phone,
            picProfile: selectedClass.teacher.picProfile,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}