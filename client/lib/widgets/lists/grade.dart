import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:halqati/models/grade_model.dart';

class GradeCard extends StatelessWidget {
  final GradeModel grade;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isTeacher;

  const GradeCard({
    super.key,
    required this.grade,
    this.onTap,
    this.onDelete,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildScoreAvatar(context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.assignment?.title ?? "general_assignment".tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(grade.dateTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTeacher && grade.card != null) ...[
                    _buildCardChip(context),
                    const SizedBox(width: 8),
                  ],
                  _buildWeightChip(context),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                ],
              ),

              // --- Description Section ---
              if (grade.description != null && grade.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 3),
                    ),
                  ),
                  child: Text(
                    grade.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreAvatar(BuildContext context) {
    final color = _getScoreColor(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          grade.score.toStringAsFixed(1),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildWeightChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "W${grade.weight}",
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildCardChip(BuildContext context) {
    String label = '';
    Color chipColor = Theme.of(context).colorScheme.primary;
    
    switch (grade.card) {
      case 3:
        label = 'card_perfect'.tr();
        break;
      case 2:
        label = 'card_very_good'.tr();
        break;
      case 1:
        label = 'card_good'.tr();
        break;
      case 0:
        label = 'card_none'.tr();
        chipColor = Colors.grey;
        break;
      default:
        label = 'card_none'.tr();
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: chipColor),
      ),
    );
  }

  Color _getScoreColor(context) {
    if (grade.score >= 15) return Theme.of(context).colorScheme.primary;
    if (grade.score >= 10) return Colors.orange;
    return Colors.redAccent;
  }
}