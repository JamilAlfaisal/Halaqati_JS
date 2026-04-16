import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/FeedItem.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/juz_api_provider.dart';
import 'package:halqati/provider/student_providers/feed_provider.dart';
import 'package:halqati/provider/student_providers/selected_feed_provider.dart';
import 'package:halqati/provider/student_providers/student_state_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/student_assingment_list.dart';
import 'package:halqati/widgets/lists/student_event_list.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/student_widgets/student_state_widget.dart';


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
        ref.read(feedProvider.notifier).markAsRead(
            assignmentId, 0
        );
        ref.invalidate(studentStatsProvider);
      }

    } catch (e) {
      debugPrint("Failed to mark as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider("feed"));
    return Scaffold(
      appBar: AppbarWithLogo(text: "events".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            SizedBox(
              height: 130,
              child: StudentStatsWidget()
            ),
            feedAsync.when(
              data: (feedItem){
                final assignmentCount = feedItem?.length??0;
                if (feedItem == null || assignmentCount == 0) {
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(feedProvider);
                        ref.invalidate(studentStatsProvider);
                        await Future.delayed(Duration(seconds: 1));
                      },
                      child: EmptyStateView()
                    ),
                  );
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: ()async {
                      ref.invalidate(studentStatsProvider);
                      ref.invalidate(feedProvider);
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: assignmentCount + (ref.watch(feedProvider.notifier).hasMore?1:0),
                        itemBuilder: (context, index) {

                          if (index >= assignmentCount) {
                            if (isLoadingMore || ref.watch(feedProvider).isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            return Center(
                              child: IconButton(
                                onPressed: () {
                                  ref.read(feedProvider.notifier).loadMore(); // ✅ NO setState
                                },
                                icon: const Icon(Icons.expand_more),
                              ),
                            );
                          }



                          final item = feedItem[index];

                          if (item.type == FeedType.assignment) {
                            final Assignment currentAssignment = item.data;

                            bool isComplete = false;
                            bool isRead = false;

                            print("wow");
                            print("is not it empty: ${currentAssignment.students.isNotEmpty}");
                            print(currentAssignment.students.length);
                            if (currentAssignment.students.isNotEmpty) {

                              print(currentAssignment.title);
                              print(currentAssignment.students[0].isComplete);
                              isComplete = currentAssignment.students[0].isComplete;
                              isRead = currentAssignment.students[0].isRead;
                            }

                            return StudentAssignmentList(
                              className: currentAssignment.halaqaClass.name,
                              isRead: isRead,
                              teacherName: currentAssignment.teacher.name,
                              title: currentAssignment.title,
                              dueDate: HelperMethods.formatDate(currentAssignment.dueDate),
                              sentTime: HelperMethods.formatDate(item.createdAt),
                              isComplete: isComplete,
                              onTap: () {
                                if (!isRead) {
                                  _markAssignmentAsRead(
                                    ref,
                                    int.tryParse(currentAssignment.id) ?? 0,
                                    index,
                                  );

                                }

                                ref.read(selectedFeedItemProvider.notifier).select(
                                  SelectedFeedItem(
                                    id: currentAssignment.id,
                                    type: FeedType.assignment,
                                  ),
                                );

                                Navigator.of(context)
                                    .pushNamed("/assignment_details_screen");
                              },
                            );
                          }

                          if (item.type == FeedType.event) {
                            final Event currentEvent = item.data;

                            return StudentEventList(
                              className: currentEvent.halaqaClass.name,
                              teacherName: currentEvent.teacher.name,
                              title: currentEvent.title,
                              date: HelperMethods.formatDate(currentEvent.dueDate),
                              sentTime: HelperMethods.formatDate(item.createdAt),
                              onTap: () {
                                ref.read(selectedFeedItemProvider.notifier).select(
                                  SelectedFeedItem(
                                    id: currentEvent.id,
                                    type: FeedType.event,
                                  ),
                                );
                                Navigator.of(context)
                                    .pushNamed("/assignment_details_screen");
                              },
                            );
                          }

                          return const SizedBox();
                        }
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
                  providerToInvalidate: feedProvider,
                );

              },
            ),
          ],
        ),
      ),
    );
  }
}
