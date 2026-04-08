import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/buttons/filter_button.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';
import 'package:collection/collection.dart';
import 'package:halqati/widgets/loading_widget.dart';

class AssignmentScreen extends ConsumerStatefulWidget {
  const AssignmentScreen({super.key});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {

  late final List<Assignment>? filteredAssignment;

  @override
  Widget build(BuildContext context) {

    final asyncAssignment = ref.watch(assignmentProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final String studentName = ref.watch(selectedStudentNameProvider)??"name".tr();
    final String studentId = ref.watch(selectedStudentIdProvider)??"0";
    final theme = Theme.of(context);
    final isLoadingMore = ref.watch(isLoadingMoreProvider("assignments"));

    return Scaffold(
      appBar: AppbarExtraButton(
        text: halaqahName,
        addBackButton: true,
        icon: Icon(
          Icons.add,
          color: theme.colorScheme.primary,
        ),
        onPress: () async {
          Navigator.of(context).pushNamed('/add_assignment_screen');
        },
      ),
      // floatingActionButton: FloatingButtonIcon(
      //   onPressed: (){
      //     Navigator.of(context).pushNamed('/add_assignment_screen');
      //   },
      //   text: "${"create".tr()} ${"assignment".tr()}",
      // ),
      body: asyncAssignment.when(
        data: (assignments){


          if(assignments == null || assignments.length == 0){
            return RefreshIndicator(
                onRefresh: ()async {
                  ref.invalidate(assignmentProvider);
                  await ref.refresh(assignmentProvider.future);
                },
              child: EmptyStateView(),
            );
          }

          return RefreshIndicator(
            onRefresh: ()async {
              ref.invalidate(assignmentProvider);
              await ref.refresh(assignmentProvider.future);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     spacing: 10,
                //     children: [
                //       FilterButton(
                //         onPressed: (){},
                //         text: "All",
                //       ),
                //       FilterButton(
                //         onPressed: (){},
                //         text: "Last Week",
                //       ),
                //       FilterButton(
                //         onPressed: (){},
                //         text: "Last Month",
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomLabel(text: studentName),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: assignments.length + (ref.watch(assignmentProvider.notifier).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {


                      if (index >= assignments.length) {
                        if (isLoadingMore) {
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
                              ref.read(assignmentProvider.notifier).loadMore(); // ✅ NO setState
                            },
                            icon: const Icon(Icons.expand_more),
                          ),
                        );
                      }

                      final students = assignments?[index].students;
                      final AssignedStudents? assignedStudent = students?.firstWhereOrNull(
                        (student) {
                          return student.student.id.toString() == studentId.toString();
                        },
                      );

                      return AssignmentList(
                          title: assignments?[index].title??"",
                          isRead: assignedStudent?.isRead??false,
                          isComplete: assignedStudent?.isComplete??false,
                          dueDate: HelperMethods.formatDate(assignments?[index].dueDate),
                          onTap: (){
                            ref.read(selectedAssignmentProvider.notifier).select(int.parse(assignments?[index].id.toString()??"0"));
                            Navigator.of(context).pushNamed("/update_assignment_screen");
                          },
                          onDelete: () async {
                            final confirm = await showConfirmationDialog(
                                context: context,
                                title: "delete_assignment".tr(),
                                message: "delete_assignment_msg".tr(),
                                cancelText: "cancel".tr(),
                                confirmText: "confirm".tr(),
                                confirmColor: Colors.red,
                            );

                            if (confirm){
                              ref
                                  .read(assignmentProvider.notifier)
                                  .deleteAssignment(
                                  assignments?[index].id ?? "0");
                            }
                          }
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => LoadingWidget(),
        error: (e, stack) {

          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomErrorWidget(
            providerToInvalidate: assignmentProvider,
          );
        },
      ),
    );
  }
}
