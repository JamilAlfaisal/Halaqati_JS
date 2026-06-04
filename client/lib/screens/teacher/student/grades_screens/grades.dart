import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/FeedItem.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/grades_notifier.dart';
import 'package:halqati/provider/student_providers/selected_feed_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/screens/teacher/student/grades_screens/add_update_grade.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/cards/proccess_data.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/grade.dart';
import 'package:halqati/widgets/loading_widget.dart';

class Grades extends ConsumerWidget {
  final bool isStudent;
  const Grades({super.key, this.isStudent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String halaqahName = ref.watch(selectedClassNameProvider) ??
        "name".tr();

    final gradesAsync = ref.watch(gradesProvider);
    final gradesNotifier = ref.watch(gradesProvider.notifier);

    final isLoadingMore = ref.watch(isLoadingMoreProvider("assignments"));


    return Scaffold(
      appBar: !isStudent ? AppbarExtraButton(
        icon: const Icon(Icons.add_chart_outlined),
        text: halaqahName,
        onPress: () {
          Navigator.of(context).pushNamed("/add_grade_screen");
        },
        addBackButton: false,
      ): AppbarWithButton(
        text: 'grades'.tr(),
        addBackButton: true,
      ),
      body: gradesAsync.when(
          data: (report) {
            if (report == null ||
                (report.history.isEmpty && report.totalWeightPoints == 0)) {
              return _buildEmptyState(context, ref);
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(gradesProvider.future),
              child: CustomScrollView(
                slivers: [

                  SliverToBoxAdapter(
                    child: GradeSummaryHeader(
                      cumulativeGrade: report.cumulativeGrade,
                      totalWeight: report.totalWeightPoints,
                      registrationDate: report.dateOfregistration ??
                          DateTime.now(),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {


                          if (index >= report.history.length) {
                            if (isLoadingMore || ref.watch(gradesProvider).isLoading) {
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
                                  ref.read(gradesProvider.notifier).loadMore();
                                },
                                icon: const Icon(Icons.expand_more),
                              ),
                            );
                          }

                          final grade = report.history[index];
                          return GradeCard(
                            grade: grade,
                            onTap: !isStudent?() {
                              Navigator.push(
                                context,
                                  MaterialPageRoute(builder: (context) => AddGradeScreen(
                                    grade: grade,
                                  )
                                ),
                              );
                            }:grade.assignment!=null?(){
                              ref.read(selectedFeedItemProvider.notifier).select(
                                SelectedFeedItem(
                                  id: grade.assignment?.id ?? "0",
                                  type: FeedType.assignment,
                                ),
                              );
                              Navigator.of(context)
                                  .pushNamed("/assignment_details_screen");
                            }:null,
                            onDelete: !isStudent?() {
                              gradesNotifier.deleteGrade(
                                  report.history[index].id);
                            }:null,
                          );
                        },
                        childCount: report.history.length + (ref.watch(gradesProvider.notifier).hasMore?1:0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (e, stack) {
            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomErrorWidget(
              providerToInvalidate: gradesProvider,
            );
          },
          loading: () => LoadingWidget()
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(gradesProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.7,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_edu, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                "not_graded_yet".tr(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Pull down to refresh".tr(),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}