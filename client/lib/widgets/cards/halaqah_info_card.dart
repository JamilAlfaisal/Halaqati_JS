import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/utils/string_transformation.dart';

class HalaqahInfoCard extends StatelessWidget {
  final String name;
  final String description;
  const HalaqahInfoCard({
    super.key,
    required this.description,
    required this.name
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = context.locale.languageCode == 'en';
    return Container(
      width: double.infinity, // Adjust width as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Half: Image with Text Overlay
            Stack(
              children: [
                Image.asset(
                  'assets/images/halaqah2.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // if (!isEnglish)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.2), // This creates the black highlighter effect
                      borderRadius: BorderRadius.circular(4), // Optional: rounds the edges
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40, // Adjusted for padding
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 150),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ),
                )

              ],
            ),
            // Second Half: Text Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description.toFirstLetterUpper(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
