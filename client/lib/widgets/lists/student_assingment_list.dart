import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/utils/string_transformation.dart';
import 'package:halqati/widgets/custom_lable.dart';

class StudentAssignmentList extends StatelessWidget {
  final String className;
  final String teacherName;
  final String title;
  final String dueDate;
  final String sentTime;
  final bool isComplete;
  final bool isRead; // ✅ NEW
  final VoidCallback onTap;

  const StudentAssignmentList({
    super.key,
    required this.className,
    required this.teacherName,
    required this.title,
    required this.dueDate,
    required this.sentTime,
    required this.isComplete,
    required this.isRead, // ✅ NEW
    required this.onTap,
  });

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
        elevation: isRead ? 2 : 4, // 🔥 unread = more elevation
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isRead
                  ? Colors.transparent
                  : theme.primaryColor.withOpacity(.4), // 🔥 unread border
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 Top Row (Label + Unread Dot)
              Row(
                children: [
                  CustomLabel(text: "assignment".tr()),
                  const Spacer(),

                  /// 🔵 Unread indicator
                  if (!isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              /// 🔹 Class + Teacher
              Row(
                children: [
                  Icon(Icons.class_, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${className.toFirstLetterUpper()} • ${teacherName.toFirstLetterUpper()}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// 🔹 Title (bold if unread)
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight:
                  isRead ? FontWeight.normal : FontWeight.bold,
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
                        isComplete
                            ? "completed".tr()
                            : "pending".tr(),
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