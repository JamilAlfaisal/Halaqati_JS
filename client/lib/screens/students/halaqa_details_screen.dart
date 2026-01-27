import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/cards/halaqah_info_card.dart';
import 'package:halqati/widgets/cards/study_time_card.dart';
import 'package:halqati/widgets/cards/teacher_details_card.dart';


class HalaqaDetailsScreen extends ConsumerWidget {
  const HalaqaDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStudentDashboard = ref.watch(studentDashboard);
    return Scaffold(
      appBar: AppbarWithButton(
        text: 'halaqah_details_screen.halaqah_details'.tr(),
        addBackButton: true
      ),
      body: asyncStudentDashboard.when(
        data: (student){
          final HalaqaClass halaqaClass = student?.halaqaClass??HalaqaClass(name: "", id: 0);
          final Teacher teacher = student?.teacher ?? Teacher();
          final assignmentCount = student?.assignmentClass?.length??0;
          final List<String> days = halaqaClass.days??[];
          // print(days);
          if(student == null){
            return Center(
              child: Text(
                'halaqah_details_screen.error_loading'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            children: [
              HalaqahInfoCard(
                description: halaqaClass.description??'not_defined'.tr(),
                name: halaqaClass.name??'not_defined'.tr(),
                capacity: halaqaClass.capacity??0,
              ),
              SizedBox(height: 20,),
              Text(
                "halaqah_details_screen.halaqah_info".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 5,),
              StudyTimeCard(
                location: halaqaClass.roomNumber??'not_defined'.tr(),
                hours: halaqaClass.time??'not_defined'.tr()
              ),
              SizedBox(height: 10),
              Text(
                'halaqah_details_screen.weekly_schedule'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 16.0,    // Gap between cards horizontally
                runSpacing: 16.0, // Gap between lines vertically
                alignment: WrapAlignment.start, // How to align cards in a row
                children: days!=[]?days.map((day) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }).toList():[
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "not_defined".tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Text(
                "halaqah_details_screen.teacher_details".tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10,),
              TeacherDetailsCard(
                name: teacher.name??"not_defined".tr(),
                email: teacher.email??"not_defined".tr(),
                phone: teacher.phone??"not_defined".tr(),
              ),
            ],
          );
        },
        loading: () => Expanded(child: const Center(child: CircularProgressIndicator())),
        error: (e, stack) {
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading halaqat",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // ✅ Add retry button for errors
                ElevatedButton(
                  onPressed: () => ref.invalidate(studentDashboard),
                  child: Text("home_screen.retry".tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
