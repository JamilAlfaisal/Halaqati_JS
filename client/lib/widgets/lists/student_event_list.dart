import 'package:flutter/material.dart';

class StudentEventList extends StatelessWidget {
  final String className;
  final String teacherName;
  final String title;
  final String date;
  final String sentTime;
  final VoidCallback onTap;

  const StudentEventList({
    super.key,
    required this.className,
    required this.teacherName,
    required this.title,
    required this.date,
    required this.sentTime,
    required this.onTap,
  });

  /// 🔴 Check if event date passed
  bool isPast(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return parsedDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = isPast(date);

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

              /// 🔥 NEW: Event Label
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
                  "Event",
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
                  Icon(Icons.event, size: 16, color: theme.primaryColor),
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

              /// 🔹 Date Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isExpired ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isExpired ? Colors.red : null,
                      fontWeight:
                      isExpired ? FontWeight.w600 : FontWeight.normal,
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
            ],
          ),
        ),
      ),
    );
  }
}