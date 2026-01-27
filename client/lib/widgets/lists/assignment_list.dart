import 'package:flutter/material.dart';
import 'package:halqati/widgets/buttons/delete_button.dart';

class AssignmentList extends StatelessWidget {
  final String title;
  final String dueDate;
  final Function onPressed;
  const AssignmentList({
    super.key,
    required this.title,
    required this.dueDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextTheme.of(context).bodyLarge,
            ),
            Text(
              dueDate,
              style: TextTheme.of(context).titleSmall,
            ),
          ],
        ),
        DeleteButton(onPressed: ()=>onPressed(),),
      ],
    );
  }
}
