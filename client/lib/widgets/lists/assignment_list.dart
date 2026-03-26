import 'package:flutter/material.dart';
import 'package:halqati/widgets/buttons/delete_button.dart';

class AssignmentList extends StatelessWidget {
  final String title;
  final String dueDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const AssignmentList({
    super.key,
    required this.title,
    required this.dueDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextTheme.of(context).bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dueDate,
                  style: TextTheme.of(context).titleSmall,
                ),
              ],
            ),
          ),
          DeleteButton(onPressed: onDelete,),
        ],
      ),
    );
  }
}
