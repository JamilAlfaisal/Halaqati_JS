import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/grade_model.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/screens/teacher/student/grades_screens/add_update_grade.dart';
import 'package:halqati/screens/teacher/student/grades_screens/set_grade_on_assignment.dart';

class StudentAssignmentTile extends ConsumerWidget {
  final String name;
  final String description;
  final String? title;
  final String? studentId;
  final String id;
  final double? score;
  final int? weight;
  final int? card;

  // Both are now optional — omit them to render without a checkbox
  final bool isSelected;
  final ValueChanged<bool?>? onToggle;

  const StudentAssignmentTile({
    super.key,
    required this.name,
    required this.description,
    required this.id,
    this.score,
    this.weight,
    this.card,
    this.title,
    this.studentId,
    this.isSelected = false,   // sensible default when checkbox is hidden
    this.onToggle,             // null → no checkbox rendered
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentId = ref.read(selectedAssignmentProvider).toString();
    final theme = Theme.of(context);
    final hasGrade = weight != 0;
    final showCheckbox = onToggle != null;

    return GestureDetector(
      onTap: hasGrade && showCheckbox
          ? () {
        ref.read(selectedStudentNameProvider.notifier).setName(name);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddGradeScreen(
              grade: GradeModel(
                weight: weight ?? 0,
                score: score ?? 0,
                card: card,
                description: description,
                id: id,
                dateTime: DateTime.now(),
                assignment: Assignment.emptyAssignment()
                    .copyWith(id: assignmentId, title: title),
              ),
            ),
          ),
        );
      }
          : (isSelected && showCheckbox)
          ? () {
        ref.read(selectedStudentNameProvider.notifier).setName(name);
        ref
            .read(selectedStudentIdProvider.notifier)
            .select(studentId ?? "");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetGradeOnAssignment(
              assignmentId: assignmentId,
              assignmentName: title ?? "",
            ),
          ),
        );
      } : !showCheckbox ? (){
        print("showCheckbox method is called");
      }:null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.secondaryContainer,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          // Checkbox is only rendered when onToggle is provided
          leading: showCheckbox
              ? Checkbox(
            value: isSelected,
            onChanged: onToggle,
            activeColor: theme.colorScheme.primary,
            side: BorderSide(
                color: theme.colorScheme.secondary, width: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          )
              : null,
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color:
              isSelected ? theme.colorScheme.primary : Colors.black87,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: hasGrade
                ? Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _InfoChip(
                  label: '${"grade".tr()}: ${score!.toStringAsFixed(1)}/20',
                  icon: Icons.grade,
                  color: theme.colorScheme.primary,
                ),
                _InfoChip(
                  label: 'W: $weight',
                  icon: Icons.scale,
                  color: theme.colorScheme.secondary,
                ),
              ],
            )
                : Text(
              'not_graded_yet'.tr(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}