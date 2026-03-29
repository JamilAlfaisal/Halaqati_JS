import 'package:flutter/material.dart';

class StudentAttendanceItem extends StatelessWidget {
  final String studentName;
  final String? subtitle; // optional (e.g., ID or class info)
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const StudentAttendanceItem({
    super.key,
    required this.studentName,
    required this.isSelected,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!isSelected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              /// Avatar (first letter)
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.primaryColor.withOpacity(.1),
                child: Text(
                  studentName.isNotEmpty
                      ? studentName[0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Name + optional subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        "${subtitle}/30 Juz",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              /// Checkbox
              Checkbox(
                value: isSelected,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}