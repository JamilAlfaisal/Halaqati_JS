import 'package:flutter/material.dart';

class StudentAssignmentList extends StatelessWidget {
  final String className;
  final String teacherName;
  final String title;
  final String dueDate;
  final String sentTime;
  final bool isComplete;
  final VoidCallback onTap;

  const StudentAssignmentList({
    super.key,
    required this.className,
    required this.teacherName,
    required this.title,
    required this.dueDate,
    required this.sentTime,
    required this.isComplete,
    required this.onTap,
  });

  /// 🔴 Check if due date passed
  bool isOverdue(String dueDate) {
    try {
      final parsedDate = DateTime.parse(dueDate);
      return parsedDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = isOverdue(dueDate);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 NEW: Assignment Label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Assignment",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// 🔹 Class + Teacher
              Row(
                children: [
                  Icon(Icons.class_, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "$className • $teacherName",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// 🔹 Title
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 Dates Row
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: overdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Due: $dueDate",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: overdue ? Colors.red : null,
                      fontWeight:
                      overdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sentTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔹 Status
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green.withOpacity(.15)
                        : Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isComplete
                            ? Icons.check_circle
                            : Icons.pending,
                        size: 14,
                        color:
                        isComplete ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isComplete ? "Completed" : "Pending",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isComplete
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}