import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/utils/string_transformation.dart';
import 'package:halqati/widgets/custom_lable.dart';

class StudentEventList extends StatelessWidget {
  final String className;
  final String teacherName;
  final String title;
  final String date;
  final String sentTime;
  final VoidCallback? onTap;

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
              CustomLabel(text: "event".tr()),
              const SizedBox(height: 8),
              /// 🔹 Class + Teacher
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${className.toFirstLetterUpper().truncate(maxLength: 20)} • ${teacherName.toFirstLetterUpper().truncate(maxLength: 20)}",
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
                title.toFirstLetterUpper(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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