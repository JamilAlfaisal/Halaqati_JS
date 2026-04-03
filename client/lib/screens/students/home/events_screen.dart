import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/services_providers/juz_api_provider.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/student_providers/student_feed_provider.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/events_list.dart';
import 'package:halqati/widgets/lists/student_assingment_list.dart';
import 'package:halqati/widgets/lists/student_event_list.dart';
import 'package:halqati/widgets/loading_widget.dart';


class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {



  void  _markAssignmentAsRead(WidgetRef ref, int assignmentId, int index) async {
    final apiService = ref.read(juzApiProvider);
    final token = ref.watch(tokenProvider).value ?? "";

    try {
      final bool isSuccess = await apiService.markAsRead(
        token: token,
        id: assignmentId,
      );

      if(isSuccess){
        debugPrint("isSuccess: ${isSuccess}");
        // ref.invalidate(studentFeedProvider);
        ref.read(studentFeedProvider.notifier).markAsRead(
            assignmentId, 0
        );
      }

    } catch (e) {
      debugPrint("Failed to mark as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(studentFeedProvider);
    final selectAssignment = ref.watch(selectedAssignmentProvider.notifier);
    return Scaffold(
      appBar: AppbarWithLogo(text: "events".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
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
                      "${"classes".tr()} ${"events".tr()} & ${"assignments".tr()}",
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
            ),
            feedAsync.when(
              data: (assignment){
                final assignmentCount = assignment?.length??0;
                if (assignment == null || assignmentCount == 0) {
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(studentFeedProvider);
                        await Future.delayed(Duration(seconds: 1));
                      },
                      child: EmptyStateView()
                    ),
                  );
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: ()async {
                      ref.invalidate(studentFeedProvider);
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: assignmentCount,
                      itemBuilder: (context, index){
                        /// please note and read carefully
                        /// here since event and assignment could
                        /// have same id so we are going to sort the list
                        /// from new to old so we are going
                        /// to save index and the provider
                        /// NOT the id

                        if (assignment[index] is Assignment){
                          assignment[index] as Assignment;
                          final Assignment currentAssignment = assignment[index];
                          bool isComplete = false;
                          bool isRead = false;

                          print(currentAssignment.students);
                          if (currentAssignment.students.length > 0){
                            isComplete = currentAssignment.students[0].isComplete;
                            isRead = currentAssignment.students[0].isRead;
                          }
                          print("events screen isRead: ${isRead}");
                          return StudentAssignmentList(
                              className: currentAssignment.halaqaClass.name,
                              isRead: isRead,
                              teacherName: currentAssignment.teacher.name,
                              title: currentAssignment.title,
                              dueDate: HelperMethods.formatDate(currentAssignment.dueDate),
                              sentTime: HelperMethods.formatDate(currentAssignment.createdDate),
                              isComplete: isComplete,
                              onTap: (){
                                if (!isRead)
                                  _markAssignmentAsRead(ref,int.tryParse(currentAssignment.id)??0, index);
                                selectAssignment.select(index);
                                Navigator.of(context).pushNamed("/assignment_details_screen");
                              }
                          );
                        }else if(assignment[index] is Event){
                          final Event currentEvent = assignment[index];
                          return StudentEventList(
                            className: currentEvent.halaqaClass.name,
                            teacherName: currentEvent.teacher.name,
                            title: currentEvent.title,
                            date: HelperMethods.formatDate(currentEvent.dueDate),
                            sentTime: HelperMethods.formatDate(currentEvent.createdDate),
                            onTap: (){
                              // selectAssignment.select(int.tryParse(currentEvent.id)??0);
                              selectAssignment.select(index);
                              Navigator.of(context).pushNamed("/assignment_details_screen");
                            }
                          );
                        }else{
                          return SizedBox();
                        }
                      },
                    ),
                  ),
                );
              },
              loading: () => Expanded(child: LoadingWidget()),
              error: (e, stack) {
                if (e is UnauthorizedException) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomErrorWidget(
                  providerToInvalidate: studentFeedProvider,
                );

              },
            ),
          ],
        ),
      ),
    );
  }
}
