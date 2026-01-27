import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/buttons/filter_button.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';

class AssignmentScreen extends ConsumerStatefulWidget {
  const AssignmentScreen({super.key});

  @override
  ConsumerState<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends ConsumerState<AssignmentScreen> {

  late final List<AssignmentClass>? assignmentList = [];
  late final List<AssignmentClass>? filteredAssignment = assignmentList;

  @override
  Widget build(BuildContext context) {

    final asyncAssignment = ref.read(assignmentProvider);
    final int studentId = ref.watch(selectedStudentIdProvider)??0;

    void handleGettingAssignments() async {

    }

    return Scaffold(
      appBar: AppbarWithButton(
        text: "student_bottom_appbar.assignments".tr(),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      FilterButton(
                        onPressed: (){},
                        text: "All",
                      ),
                      FilterButton(
                        onPressed: (){},
                        text: "Last Week",
                      ),
                      FilterButton(
                        onPressed: (){},
                        text: "Last Month",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50,),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAssignment?.length??0,
                    itemBuilder: (context, index) {
                      return studentId == filteredAssignment?[index].studentId?
                      AssignmentList(
                          title: filteredAssignment?[index].title??"",
                          dueDate: filteredAssignment?[index].dueDate??"",
                          onPressed: (){}
                      ):SizedBox();
                    },
                  ),
                ),
              ],
            )
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
