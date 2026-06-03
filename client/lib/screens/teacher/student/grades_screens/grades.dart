import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/grades_notifier.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/screens/teacher/student/grades_screens/add_update_grade.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
import 'package:halqati/widgets/cards/proccess_data.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/grade.dart';
import 'package:halqati/widgets/loading_widget.dart';

class Grades extends ConsumerWidget {
  const Grades({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String halaqahName = ref.watch(selectedClassNameProvider) ??
        "name".tr();

    final gradesAsync = ref.watch(gradesProvider);
    final gradesNotifier = ref.watch(gradesProvider.notifier);

    return Scaffold(
      appBar: AppbarExtraButton(
        icon: const Icon(Icons.add_chart_outlined),
        text: halaqahName,
        onPress: () {
          Navigator.of(context).pushNamed("/add_grade_screen");
        },
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
                          final grade = report.history[index];
                          return GradeCard(
                            grade: grade,
                            onTap: () {
                              Navigator.push(
                                context,
                                  MaterialPageRoute(builder: (context) => AddGradeScreen(
                                    grade: grade,
                                  )
                                ),
                              );
                            },
                            onDelete: () {
                              gradesNotifier.deleteGrade(
                                  report.history[index].id);
                            },
                          );
                        },
                        childCount: report.history.length,
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
              providerToInvalidate: studentsProvider,
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