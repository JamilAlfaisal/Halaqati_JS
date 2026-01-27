import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/cards/date_type_card.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/provider/api_service_provider.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {

  String displayDate(String? date){
    if (date == "" || date == null){
      return "00-00-00";
    }
    return date.split("T")[0];
  }
  bool submitting = false;
  @override
  Widget build(BuildContext context) {
    final asyncStudentDashboard = ref.watch(studentDashboard);
    final selectAssignment = ref.watch(selectedAssignmentProvider);
    final apiService = ref.read(apiServiceProvider);
    final token = ref.watch(tokenProvider).value??"";
    // print("selectAssignment: ${selectAssignment}");

    return Scaffold(
      appBar: AppbarWithButton(
        text: "event_details_screen.event_details".tr(),
        addBackButton: true
      ),
      body: asyncStudentDashboard.when(
        data: (student){
          final HalaqaClass halaqaClass = student?.halaqaClass??HalaqaClass(name: "", id: 0);
          final Teacher teacher = student?.teacher ?? Teacher();
          final List<AssignmentClass> assignments = student?.assignmentClass ?? [];
          final AssignmentClass assignmentDetails = assignments.firstWhere(
              (assignment){
                return assignment.id == selectAssignment;
              }
          );
          final List<int> pages = assignmentDetails.pages??[];
          if(student == null){
            return Center(
              child: Text(
                'halaqah_details_screen.error_loading'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              assignmentDetails.title??"not_defined".tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (assignmentDetails.isCompleted??false)?
                              Theme.of(context).colorScheme.primary:
                              Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (assignmentDetails.isCompleted??false)?
                                  Icons.timer_off_outlined
                                  :Icons.timer_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                SizedBox(width: 20,),
                                Text(
                                  assignmentDetails.isCompleted??false?
                                  "event_details_screen.done".tr():
                                  "event_details_screen.pending".tr(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
                      DateTypeCard(
                        date: displayDate(assignmentDetails.dueDate),
                        type: assignmentDetails.type??"not_defined".tr(),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "event_details_screen.teacher_instructions".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10,),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                          ],
                        ),
                        child: Text(
                          assignmentDetails.description??"not_defined".tr(),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "event_details_screen.pages".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: pages.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: PageNumber(
                                  onPressed: (){},
                                  num: pages[index],
                                  selected: false
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: assignmentDetails.isCompleted??false?null:!submitting?() async {

                    setState(() {
                      submitting = true;
                    });

                    final bool success = await apiService.markAsComplete(
                      token: token,
                      id: selectAssignment??0
                    );

                    if(success){
                      ref.invalidate(studentDashboard);
                    }

                    setState(() {
                      submitting = false;
                    });

                  }:null,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: assignmentDetails.isCompleted??false?
                      Colors.grey.shade300:
                      Theme.of(context).colorScheme.secondary,
                    ),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Spacer(),
                        Icon(Icons.checklist_rounded),
                        SizedBox(width: 10,),
                        Text(
                          "event_details_screen.mark_as_complete".tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom
                ))
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
