import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/FeedItem.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/provider/student_providers/feed_provider.dart';
import 'package:halqati/provider/services_providers/juz_api_provider.dart';
import 'package:halqati/provider/student_providers/student_state_provider.dart';
import 'package:halqati/provider/services_providers/event_api_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/cards/grade_detail_card.dart';
import 'package:halqati/widgets/cards/date_type_card.dart';
import 'package:halqati/widgets/buttons/page_number.dart';
import 'package:halqati/widgets/lists/StudentAssignmentList.dart';

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
    return date.toString().split(" ")[0];
  }

  FeedItem? selectedItem;
  bool isLoading = true;
  bool? _myConfirmation; // null = pending, true = yes, false = no
  bool _confirmationLoaded = false;


  void fetchingFeedItems () async {
    isLoading = true;
    final item = await ref.read(feedProvider.notifier).getSelectedItemFromBackEnd();

    bool? initialConfirmation;
    if (item?.type == FeedType.event) {
      final eventData = item?.data as Event?;
      if (eventData?.confirmation == true) {
        final token = ref.read(tokenProvider).value ?? "";
        if (token.isNotEmpty && eventData?.id != null) {
          try {
            initialConfirmation = await ref.read(eventApiProvider).getMyEventConfirmation(token, eventData!.id);
          } catch (e) {
            debugPrint("Failed to fetch confirmation: $e");
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        selectedItem = item;
        _myConfirmation = initialConfirmation;
        _confirmationLoaded = true;
        isLoading = false;
      });
    }
  }
  @override
  void initState() {
    fetchingFeedItems();
    super.initState();
  }

  void _confirmEvent(String eventId, bool isConfirmed) {
    final passwordController = TextEditingController();
    // ✅ Capture before dialog opens so context stays valid after pop
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final token = ref.read(tokenProvider).value ?? "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: Text("password_required".tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("enter_password_confirm".tr()),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "password".tr(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text("cancel".tr()),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (passwordController.text.isEmpty) return;
                          setDialogState(() => isSubmitting = true);
                          try {
                            await ref.read(eventApiProvider).confirmEvent(
                                  token: token,
                                  eventId: eventId,
                                  isConfirmed: isConfirmed,
                                  password: passwordController.text,
                                );
                            // ✅ Pop dialog with its own context
                            Navigator.pop(dialogContext);
                            // ✅ Update parent state - no invalid context issue
                            setState(() {
                              _myConfirmation = isConfirmed;
                              _confirmationLoaded = true;
                            });
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text("success".tr())),
                            );
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text("confirm_attendance".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // final selectedItem = ref.read(feedProvider.notifier).getSelectedItemFromBackEnd();
    final apiService = ref.read(juzApiProvider);
    final token = ref.watch(tokenProvider).value ?? "";
    final feedState = ref.watch(feedProvider);

    if (feedState.isLoading || isLoading){
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
          final isAssignment = selectedItem?.type == FeedType.assignment;
          final assignment =
          isAssignment ? selectedItem?.data as Assignment : null;
          final event =
          !isAssignment ? selectedItem?.data as Event : null;


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

          final isCompleted = isAssignment
              ? assignment!.students
              .any((s) => s.isComplete)
              : false;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                   onRefresh: ()  async {
                     ref.invalidate(studentStatsProvider);
                     fetchingFeedItems();
                   },
                  child: ListView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 10
                    ),
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

                      DateTypeCard(
                        date: displayDate(dueDate),
                        type: isAssignment
                            ? "${assignment!.type.toLowerCase()}".tr()
                            : "event".tr(),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "$className • $teacherName",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 20),

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
                      SizedBox(height: 10,),
                      if (isAssignment) ...[
                        GradeDetailCard(
                          grade: assignment?.grade,
                        ),
                        SizedBox(height: 10,),
                        Container(
                          height: MediaQuery.of(context).size.height*0.4,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.builder(
                            itemCount: assignment?.students.length??0,
                            itemBuilder: (context, index){
                              return StudentAssignmentTile(
                                name: assignment?.students[index].student.name??"undefined".tr(),
                                description: '',
                                id: assignment?.students[index].student.id??"0",
                                weight: assignment?.students[index].grade?.weight??0,
                                score: assignment?.students[index].grade?.score??0.0,
                                studentId: assignment?.students[index].student.id??"0",
                                onToggle: null,
                              );
                            },
                          ),
                        )
                      ]
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
                        ref.read(feedProvider.notifier).markAsCompleted(assignment?.id ??"0");
                        fetchingFeedItems();
                        ref.invalidate(studentStatsProvider);
                      }

                      setState(() {
                        submitting = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom
                      ),
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

              /// 🔥 CONFIRM EVENT (EVENT ONLY)
              if (!isAssignment && event!.confirmation)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _confirmationLoaded && _myConfirmation != null
                      // ✅ Already answered — show status banner
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _myConfirmation == true
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _myConfirmation == true ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _myConfirmation == true ? Icons.check_circle : Icons.cancel,
                                color: _myConfirmation == true ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _myConfirmation == true
                                      ? "yes_will_attend".tr()
                                      : "no_will_not_attend".tr(),
                                  style: TextStyle(
                                    color: _myConfirmation == true ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _confirmationLoaded = false;
                                    _myConfirmation = null;
                                  });
                                },
                                child: Text("change".tr()),
                              )
                            ],
                          ),
                        )
                      // ✅ Not yet answered — show Yes/No buttons
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () => _confirmEvent(event.id, true),
                                child: Text("yes_will_attend".tr(), style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () => _confirmEvent(event.id, false),
                                child: Text("no_will_not_attend".tr(), style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom), 
               
            ],
          );
        },
      ),
    );
  }
}