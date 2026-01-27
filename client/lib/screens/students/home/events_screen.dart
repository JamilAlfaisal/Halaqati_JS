import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/lists/events_list.dart';


class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {

  String displayDate(String? date){
    if (date == "" || date == null){
      return "00-00-00";
    }
    return date.split("T")[0];
  }

  @override
  Widget build(BuildContext context) {
    final asyncStudentDashboard = ref.watch(studentDashboard);
    final selectAssignment = ref.watch(selectedAssignmentProvider.notifier);
    return Scaffold(
      appBar: AppbarWithLogo(text: "student_app_bar.events.title".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 230,
                  width: double.maxFinite,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  child: Image.asset(
                    'assets/images/alsham.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    "dashboard_screen.halaqah_events".tr(),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                      fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
                      fontWeight: Theme.of(context).textTheme.titleLarge?.fontWeight,
                      background: Paint()
                        ..color = Colors.black.withOpacity(0.2)
                        ..strokeWidth = 15
                        ..style = PaintingStyle.stroke,
                    ),
                  ),
                )
              ],
            ),
            asyncStudentDashboard.when(
              data: (student){
                final HalaqaClass halaqaClass = student?.halaqaClass??HalaqaClass(name: "", id: 0);
                final Teacher teacher = student?.teacher ?? Teacher();
                final List<AssignmentClass> assignmentClass = student?.assignmentClass??[];
                final assignmentCount = student?.assignmentClass?.length??0;
                if (student == null || assignmentCount == 0) {
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(studentDashboard);
                        await Future.delayed(Duration(seconds: 1));
                      },
                      child: ListView(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 50),
                              child: Center(
                                child: Text(
                                  "dashboard_screen.no_assignments".tr(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: ()async {
                      ref.refresh(studentDashboard);
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: assignmentClass.length,
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: (){
                            selectAssignment.select(assignmentClass[index].id??0);
                            Navigator.of(context).pushNamed("/event_details_screen");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: EventsList(
                              title: assignmentClass[index].title??"",
                              date: displayDate(assignmentClass[index].dueDate),
                              description: assignmentClass[index].description??"",
                              isComplete: assignmentClass[index].isCompleted??false,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
            // EventsList(title: "Weekly Halaqa", date: "2024-07-20", description: "dvgfhgddfgvfgfhgjhhgjjhfghfvgdsvfvbfbghgnhmjhkyhhfvcv vb ")
          ],
        ),
      ),
    );
  }
}
