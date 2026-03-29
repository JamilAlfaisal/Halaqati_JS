import 'package:flutter/material.dart';
import 'package:halqati/widgets/buttons/delete_button.dart';

class AttendanceList extends StatelessWidget {
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AttendanceList({
    super.key,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              /// Left icon (calendar for attendance)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: theme.primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              /// Date
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              /// Delete button
              DeleteButton(onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}