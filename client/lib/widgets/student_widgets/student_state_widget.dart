import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/provider/student_providers/student_state_provider.dart';


class StudentStatsWidget extends ConsumerStatefulWidget {
  const StudentStatsWidget({super.key});

  @override
  ConsumerState<StudentStatsWidget> createState() =>
      _StudentStatsWidgetState();
}

class _StudentStatsWidgetState
    extends ConsumerState<StudentStatsWidget> {

  Future<void> _refresh() async {
    await ref.read(studentStatsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(studentStatsProvider);

    return statsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox(),
      data: (stats) {
        if (stats == null) return const SizedBox();
        final int unread = stats.totalAssignments - stats.readAssignments;
        return SizedBox(
          height: 90,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _MiniStatCard(
                  label: "uncompleted".tr(),
                  value: stats.notCompletedAssignments,
                  icon: Icons.pending_actions,
                ),
                _MiniStatCard(
                  label: "unread".tr(),
                  value: unread,
                  icon: Icons.visibility_off,
                ),
                _MiniStatCard(
                  label: "assignments".tr(),
                  value: stats.totalAssignments,
                  icon: Icons.menu_book,
                ),
                // _MiniStatCard(
                //   label: "pending".tr(),
                //   value: stats.notCompletedAssignments,
                //   icon: Icons.schedule,
                // ),
                _MiniStatCard(
                  label: "events".tr(),
                  value: stats.totalEvents,
                  icon: Icons.event,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final String stringValue = value > 9999999?"999999+":value.toString();
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            stringValue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}