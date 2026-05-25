import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart'; // Using the existing logic for delete
import 'package:halqati/screens/teacher/student/assignment_screens/add_assignment_screen.dart';
import 'package:halqati/screens/teacher/student/assignment_screens/update_assignment_screen.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/provider/teacher_providers/class_assignment_provider.dart';

class AllAssignmentsScreen extends ConsumerStatefulWidget {
  const AllAssignmentsScreen({super.key});

  @override
  ConsumerState<AllAssignmentsScreen> createState() => _AllAssignmentsScreenState();
}

class _AllAssignmentsScreenState extends ConsumerState<AllAssignmentsScreen> {
  @override
  Widget build(BuildContext context) {

    final asyncAssignments = ref.watch(classAssignmentsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider) ?? "name".tr();
    final theme = Theme.of(context);

    final isLoadingMore = ref.watch(isLoadingMoreProvider("class_assignments"));

    return Scaffold(
      appBar: AppbarExtraButton(
        text: halaqahName,
        addBackButton: true,
        icon: Icon(
          Icons.add,
          color: theme.colorScheme.primary,
        ),
        onPress: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAssignmentScreen(
              forManyStudents: true,
            )),
          );
        },
      ),
      body: asyncAssignments.when(
        data: (assignments) {
          if (assignments == null || assignments.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(classAssignmentsProvider);
                await ref.refresh(classAssignmentsProvider.future);
              },
              child: const EmptyStateView(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(classAssignmentsProvider);
              await ref.refresh(classAssignmentsProvider.future);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: assignments.length + (ref.watch(classAssignmentsProvider.notifier).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Pagination logic
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
                              ref.read(classAssignmentsProvider.notifier).loadMore();
                            },
                            icon: const Icon(Icons.expand_more),
                          ),
                        );
                      }

                      final assignment = assignments[index];

                      return AssignmentList(
                        title: assignment.title,
                        dueDate: HelperMethods.formatDate(assignment.dueDate),
                        seeGrade: null,
                        onTap: () {
                          ref.read(selectedAssignmentProvider.notifier).select(int.parse(assignment.id.toString()));
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  UpdateAssignmentScreen(
                              generalAssignment: false,
                            )),
                          );

                        },
                        setGrade: null,
                        onDelete: () async {
                          final confirm = await showConfirmationDialog(
                            context: context,
                            title: "delete_assignment".tr(),
                            message: "delete_assignment_msg".tr(),
                            cancelText: "cancel".tr(),
                            confirmText: "confirm".tr(),
                            confirmColor: Colors.red,
                          );

                          if (confirm) {
                            // We use the delete method from the main assignmentProvider.notifier
                            // because it already has the API logic implemented.
                            await ref
                                .read(assignmentProvider.notifier)
                                .deleteAssignment(assignment.id);

                            // Refresh the class list to show it's gone
                            ref.invalidate(classAssignmentsProvider);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, stack) {
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomErrorWidget(
            providerToInvalidate: classAssignmentsProvider,
          );
        },
      ),
    );
  }
}