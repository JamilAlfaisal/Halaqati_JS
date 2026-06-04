import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GradeSummaryHeader extends StatelessWidget {
  final double cumulativeGrade;
  final int totalWeight;
  final DateTime registrationDate;

  const GradeSummaryHeader({
    super.key,
    required this.cumulativeGrade,
    required this.totalWeight,
    required this.registrationDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "academic_overview".tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Cumulative Grade Card
              Expanded(
                flex: 3,
                child: _buildSummaryCard(
                  context,
                  title: "cumulative_grade".tr(),
                  value: cumulativeGrade.toStringAsFixed(2),
                  subtitle: "${"out_of".tr()} 20",
                  icon: Icons.analytics_rounded,
                  color: _getGradeColor(context),
                  // Adding a small progress line
                  extra: LinearProgressIndicator(
                    value: cumulativeGrade / 20,
                    backgroundColor: _getGradeColor(context).withOpacity(0.1),
                    color: _getGradeColor(context),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Registration Date Card
              Expanded(
                flex: 2,
                child: _buildSummaryCard(
                  context,
                  title: "enrolled_since".tr(),
                  value: DateFormat('MMM yyyy').format(registrationDate),
                  subtitle: "${"total_weight".tr()}: $totalWeight",
                  icon: Icons.calendar_today_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, {
        required String title,
        required String value,
        required String subtitle,
        required IconData icon,
        required Color color,
        Widget? extra,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra,
          ],
        ],
      ),
    );
  }

  Color _getGradeColor(context) {
    if (cumulativeGrade >= 15) return Theme.of(context).colorScheme.primary;
    if (cumulativeGrade >= 10) return Colors.orange;
    return Colors.redAccent;
  }
}