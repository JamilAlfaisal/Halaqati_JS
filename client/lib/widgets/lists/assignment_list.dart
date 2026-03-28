import 'package:flutter/material.dart';
import 'package:halqati/widgets/buttons/delete_button.dart';

class AssignmentList extends StatelessWidget {
  final String title;
  final String dueDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool? isComplete;

  const AssignmentList({
    super.key,
    required this.title,
    required this.dueDate,
    required this.onTap,
    required this.onDelete,
    this.isComplete,
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
              /// Left icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: theme.primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              /// Title + Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dueDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Completion badge
              if (isComplete != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isComplete!
                        ? Colors.green.withOpacity(.15)
                        : Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isComplete! ? Icons.check_circle : Icons.pending,
                        size: 14,
                        color: isComplete! ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isComplete! ? "Completed" : "Pending",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                          isComplete! ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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