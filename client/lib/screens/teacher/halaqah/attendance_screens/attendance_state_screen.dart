import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/teacher_providers/attendnace_state_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class AttendanceStateScreen extends ConsumerStatefulWidget {
  const AttendanceStateScreen({super.key});

  @override
  ConsumerState<AttendanceStateScreen> createState() =>
      _AttendanceStateScreenState();
}

class _AttendanceStateScreenState
    extends ConsumerState<AttendanceStateScreen> {
  DateTime? _selectedDate;

  Future<void> _fetchData() async {
    if (_selectedDate != null) {
      await ref
          .read(attendanceStatsProvider.notifier)
          .setStartDateAndFetch(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(attendanceStatsProvider);

    return Scaffold(
      appBar: AppbarWithButton(
        text: "attendance_state".tr(),
        addBackButton: true,
      ),
      body: Column(
        children: [
          /// 🔹 Date Picker + Fetch Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : "select_date".tr(),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectedDate == null ? null : _fetchData,
                  child: Text("fetch".tr()),
                ),
              ],
            ),
          ),

          /// 🔹 Attendance List
          Expanded(
            child: statsAsync.when(
              loading: () => LoadingWidget(),
              error: (e, stack) {
                if (e is UnauthorizedException) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomErrorWidget(
                  providerToInvalidate: attendanceStatsProvider,
                );
              },
              data: (stats) {
                if (stats == null || stats.isEmpty) {
                  return EmptyStateView();
                }

                /// Sort by attendance count descending
                final sorted = [...stats]
                  ..sort((a, b) => b.attendanceCount.compareTo(a.attendanceCount));

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(attendanceStatsProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final student = sorted[index];
                      return _StudentAttendanceCard(
                        index: index,
                        name: student.name,
                        count: student.attendanceCount,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceCard extends StatelessWidget {
  final int index;
  final String name;
  final int count;

  const _StudentAttendanceCard({
    required this.index,
    required this.name,
    required this.count,
  });

  Color _getRankColor(BuildContext context) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getRankIcon() {
    if (index == 0) return Icons.emoji_events;
    if (index == 1) return Icons.emoji_events_outlined;
    if (index == 2) return Icons.workspace_premium;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(_getRankIcon(), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "times".tr(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}