

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/grade_model.dart';

class GradeDetailCard extends StatelessWidget {
  final GradeModel? grade;

  const GradeDetailCard({
    super.key,
    this.grade,
  });

  bool get _hasGrade => grade != null && (grade!.weight) != 0;

  Color _gradeColor(double percentage, context) {
    if (percentage >= 0.75) return Theme.of(context).colorScheme.primary;
    if (percentage >= 0.50) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  String _gradeLabel(double percentage) {
    if (percentage >= 0.90) return 'excellent'.tr();
    if (percentage >= 0.75) return 'good'.tr();
    if (percentage >= 0.50) return 'average'.tr();
    return 'needs_improvement'.tr();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasGrade) return _NoGradeCard(context);

    final theme = Theme.of(context);
    final double score = grade!.score;
    final int weight = grade!.weight;         // 1, 2, or 3
    final String? notes = grade!.description!.trim().isEmpty
        ? null
        : grade!.description;
    const double maxScore = 20;
    final double percentage = (score / maxScore).clamp(0.0, 1.0);
    final Color gradeColor = _gradeColor(percentage, context);
    final bool hasNotes = notes != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradeColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          _CardHeader(gradeColor: gradeColor, label: _gradeLabel(percentage)),

          // ── Stats row ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.grade_rounded,
                    label: 'score'.tr(),
                    value: '${score.toStringAsFixed(1)} / $maxScore',
                    color: gradeColor,
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.scale_rounded,
                    label: 'weight'.tr(),
                    value: _weightStars(weight),   // ★ ★ ★ style
                    color: Theme.of(context).colorScheme.secondary,
                    isStars: true,
                  ),
                ),
                _Divider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.percent_rounded,
                    label: 'percentage'.tr(),
                    value: '${(percentage * 100).toStringAsFixed(0)}%',
                    color: gradeColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Progress bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: gradeColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              ),
            ),
          ),

          // ── Notes ────────────────────────────────────────────────
          if (hasNotes) ...[
            Divider(height: 1, thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
              indent: 16, endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Converts weight 1/2/3 → filled star string
  String _weightStars(int weight) {
    final filled = '★' * weight.clamp(0, 3);
    final empty  = '☆' * (3 - weight.clamp(0, 3));
    return '$filled$empty';
  }

  /// "Not graded yet" empty state card
  Widget _NoGradeCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 22,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'not_graded_yet'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'grade_pending_message'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final Color gradeColor;
  final String label;
  const _CardHeader({required this.gradeColor, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(Icons.school_rounded, size: 18, color: gradeColor),
          const SizedBox(width: 8),
          Text(
            'grade_details'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: gradeColor,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gradeColor.withOpacity(0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: gradeColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isStars;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isStars = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: isStars
              ? TextStyle(fontSize: 16, color: color, letterSpacing: 2)
              : theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 48,
    color: Theme.of(context).colorScheme.outlineVariant,
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}