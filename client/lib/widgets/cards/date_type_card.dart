import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class DateTypeCard extends StatelessWidget {
  final String type;
  final String date;
  const DateTypeCard({
    super.key,
    required this.date,
    required this.type
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity, // Adjust width as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    ),
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: Theme.of(context).textTheme.bodyMedium,
                          // overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "event_details_screen.type".tr(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  )
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  height: 0,
                  thickness: 0.2,
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    ),
                    child: Icon(Icons.calendar_today),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "event_details_screen.date".tr(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        )
    );
  }
}
