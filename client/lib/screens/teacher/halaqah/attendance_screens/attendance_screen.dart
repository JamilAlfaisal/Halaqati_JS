import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/attendance_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_action_list.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/attendance_list.dart';
import 'package:halqati/widgets/loading_widget.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final attendancesAsync = ref.watch(attendanceProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final isLoadingMore = ref.watch(isLoadingMoreProvider("attendance"));

    return Scaffold(

      appBar: AppbarWithActionList(
        text: halaqahName,
        addBackButton: true,
        actionList: [
          TextButton(
              onPressed: (){
                Navigator.of(context).pushNamed("/take_attendance_screen");
              },
              child: Text("${"take".tr()} ${"attendance".tr()}")
          ),
          TextButton(
              onPressed: (){
                Navigator.of(context).pushNamed("/attendance_state_screen");
              },
              child: Text("attendance_state".tr())
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceProvider);
        },
        child: attendancesAsync.when(
          data: (attendances) {
            if (attendances == null || attendances.length == 0) {
              return EmptyStateView();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: attendances.length  + (ref.watch(attendanceProvider.notifier).hasMore ? 1 : 0),
              itemBuilder: (context, index) {

                if (index >= attendances.length) {
                  if (isLoadingMore || ref.watch(attendanceProvider).isLoading) {
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
                        ref.read(attendanceProvider.notifier).loadMore();
                      },
                      icon: const Icon(Icons.expand_more),
                    ),
                  );
                }

                final attendance = attendances[index];

                return AttendanceList(
                  date: HelperMethods.formatDate(attendance.date),
                  onTap: ref.watch(attendanceProvider).isLoading?(){}:() {
                    ref.read(selectedAttendanceProvider.notifier).state =
                        attendance.id.toString();
                    Navigator.of(context).pushNamed("/attendance_details_screen");
                  },
                  onDelete: () async {
                    ref.read(selectedAttendanceProvider.notifier).state =
                        attendance.id.toString();
                    final confirm = await showConfirmationDialog(
                      context: context,
                      title: "delete_attendance".tr(),
                      message: "delete_attendance_msg".tr(),
                      cancelText: "cancel".tr(),
                      confirmText: "confirm".tr(),
                      confirmColor: Colors.red,
                    );
                    if (confirm){
                      try {
                        await ref
                            .read(attendanceProvider.notifier)
                            .deleteAttendance();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${"error".tr()}: $e")),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
          loading: () => LoadingWidget(),
          error: (e, stack) {
            print("error in the event screen: ${e}");
            if (e is UnauthorizedException) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomErrorWidget(
              providerToInvalidate: attendanceProvider,
            );
          },
        ),
      ),
    );
  }
}