import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/buttons/filter_button.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';
import 'package:collection/collection.dart';

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

    return Scaffold(
      appBar: AppbarWithButton(
        text: halaqahName,
        addBackButton: true,
      ),
      floatingActionButton: FloatingButtonIcon(
        onPressed: (){
          Navigator.of(context).pushNamed('/add_assignment_screen');
        },
        text: "student_bottom_appbar.assignment.new_assignment".tr(),
      ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  margin: EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    studentName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: assignments?.length??0,
                    itemBuilder: (context, index) {
                      final students = assignments?[index].students;
                      final AssignedStudents? assignedStudent = students?.firstWhereOrNull(
                        (student) {
                          return student.student.id.toString() == studentId.toString();
                        },
                      );

                      print(assignedStudent?.isComplete);

                      return AssignmentList(
                          title: assignments?[index].title??"",
                          isComplete: assignedStudent?.isComplete??false,
                          dueDate: HelperMethods.formatDate(assignments?[index].dueDate),
                          onTap: (){
                            ref.read(selectedAssignmentProvider.notifier).select(int.parse(assignments?[index].id.toString()??"0"));
                            Navigator.of(context).pushNamed("/update_assignment_screen");
                          },
                          onDelete: (){
                            ref.read(assignmentProvider.notifier).deleteAssignment(assignments?[index].id??"0");
                          }
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {

          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading assignments",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // ✅ Add retry button for errors
                ElevatedButton(
                  onPressed: () => ref.invalidate(assignmentProvider),
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
