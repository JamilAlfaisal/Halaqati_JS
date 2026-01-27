import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';

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

    final asyncAssignment = ref.watch(assignmentProvider);
    final int studentId = ref.watch(selectedStudentIdProvider)??0;
    return Scaffold(
      appBar: AppbarWithButton(
          text: "event_details_screen.event_details".tr(),
          addBackButton: true
      ),
      body: asyncAssignment.when(
        data: (assignments){

          if(assignments == null){
            return Center(
              child: Text(
                'halaqah_details_screen.error_loading'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return Expanded(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                return studentId == assignments[index].studentId?
                AssignmentList(
                    title: assignments[index].title??"",
                    dueDate: assignments[index].dueDate??"",
                    onPressed: (){}
                ):SizedBox();
              },
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
