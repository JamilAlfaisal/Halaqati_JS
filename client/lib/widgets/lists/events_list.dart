import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EventsList extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final bool isComplete;
  final void Function()? onTap;
  const EventsList({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.isComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,               // Better than clip
                    // maxLines: 2,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,               // Better than clip
                    // maxLines: 2,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,               // Better than clip
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  color: isComplete?
                  Theme.of(context).colorScheme.primary:
                  Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16)
              ),
              child: Text(
                isComplete?
                "event_details_screen.done".tr():
                "event_details_screen.pending".tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
