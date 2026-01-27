import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class StudyTimeCard extends StatelessWidget {
  final String hours;
  final String location;
  const StudyTimeCard({
    super.key,
    required this.location,
    required this.hours,
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
                  child: Icon(Icons.location_on_outlined),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("halaqah_details_screen.location".tr()),
                      Text(
                        location,
                        style: Theme.of(context).textTheme.labelSmall,
                        // overflow: TextOverflow.ellipsis,
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
                  child: Icon(Icons.access_time_rounded),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("halaqah_details_screen.time".tr()),
                      Text(
                        hours,
                        style: Theme.of(context).textTheme.labelSmall,
                        // overflow: TextOverflow.ellipsis,
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
