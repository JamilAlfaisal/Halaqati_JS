import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/provider/student_providers/student_feed_provider.dart';
import 'package:halqati/provider/services_providers/juz_api_provider.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/cards/date_type_card.dart';
import 'package:halqati/widgets/buttons/page_number.dart';

class AssignmentDetailsScreen extends ConsumerStatefulWidget {
  const AssignmentDetailsScreen({super.key});

  @override
  ConsumerState<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState
    extends ConsumerState<AssignmentDetailsScreen> {
  bool submitting = false;

  String displayDate(DateTime? date) {
    if (date == null) return "00-00-00";
    return date.toString().split("T")[0];
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(studentFeedProvider.notifier).getSelectedItem();
    final apiService = ref.read(juzApiProvider);
    final token = ref.watch(tokenProvider).value ?? "";
    if (ref.watch(studentFeedProvider).isLoading){
      return Scaffold(
        body: Center(
          child: const Center(child: CircularProgressIndicator(),
        ),
      )
      );
    }
    return Scaffold(
      appBar: AppbarWithButton(
        text: "details".tr(),
        addBackButton: true,
      ),

      /// 🔥 LOADING / EMPTY
      body: selectedItem == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(
        builder: (_) {
          /// 🔥 TYPE CHECK
          final isAssignment = selectedItem is Assignment;
          print("is the selected list is assignment: ${isAssignment}");
          final assignment =
          isAssignment ? selectedItem as Assignment : null;
          final event =
          !isAssignment ? selectedItem as Event : null;

          /// 🔥 COMMON DATA
          final title =
          isAssignment ? assignment!.title : event!.title;

          final description = isAssignment
              ? assignment!.description
              : event!.description;

          final dueDate = isAssignment
              ? assignment!.dueDate
              : event!.dueDate;

          final teacherName = isAssignment
              ? assignment!.teacher.name
              : event!.teacher.name;

          final className = isAssignment
              ? assignment!.halaqaClass.name
              : event!.halaqaClass.name;

          final pages = isAssignment ? assignment!.pages : [];

          /// 🔥 Completion logic (Assignment only)
          final isCompleted = isAssignment
              ? assignment!.students
              .any((s) => s.isComplete)
              : false;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    children: [
                      /// 🔹 TITLE + STATUS
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge,
                            ),
                          ),

                          /// ✅ ONLY FOR ASSIGNMENT
                          if (isAssignment)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    : Theme.of(context)
                                    .colorScheme
                                    .secondary,
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Icons
                                        .timer_off_outlined
                                        : Icons.timer_outlined,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isCompleted
                                        ? "completed".tr()
                                        .tr()
                                        : "pending".tr()
                                        .tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// 🔹 DATE + TYPE
                      DateTypeCard(
                        date: displayDate(dueDate),
                        type: isAssignment
                            ? "${assignment!.type.toLowerCase()}".tr()
                            : "event".tr(),
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 CLASS + TEACHER
                      Text(
                        "$className • $teacherName",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 DESCRIPTION
                      Text(
                        "des".tr()
                            .tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2),
                          ],
                        ),
                        child: Text(description),
                      ),

                      /// 🔥 PAGES ONLY FOR ASSIGNMENT
                      if (isAssignment) ...[
                        const SizedBox(height: 20),
                        Text(
                          "pages".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection:
                            Axis.horizontal,
                            itemCount: pages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: SizedBox(
                                  width: 50,
                                  child: PageNumber(
                                    onPressed: () {},
                                    num: int.tryParse(
                                        pages[index]) ??
                                        0,
                                    selected: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              /// 🔥 MARK AS COMPLETE (ASSIGNMENT ONLY)
              if (isAssignment)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: isCompleted || submitting
                        ? null
                        : () async {
                      setState(() {
                        submitting = true;
                      });

                      final success =
                      await apiService
                          .markAsComplete(
                        token: token,
                        id: int.tryParse(assignment?.id??"0")??0,
                      );

                      if (success) {
                        setState(() {
                          ref.invalidate(
                              studentFeedProvider);
                        });
                      }

                      setState(() {
                        submitting = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(15),
                        color: isCompleted
                            ? Colors.grey.shade300
                            : Theme.of(context)
                            .colorScheme
                            .secondary,
                      ),
                      child: Row(
                        children: [
                          const Spacer(),
                          const Icon(Icons.checklist_rounded),
                          const SizedBox(width: 10),
                          Text(
                            "mark_as_complete"
                                .tr(),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.only(
                  bottom:
                  MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}