import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherDetailsCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const TeacherDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      debugPrint("Could not launch phone");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      debugPrint("Could not launch email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String firstLetter =
    name.isNotEmpty ? name.trim()[0].toUpperCase() : "?";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Top Section (Avatar + Name + Actions)
          Row(
            children: [
              /// Avatar with fallback
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.primaryColor.withOpacity(.1),
                child: Text(
                  firstLetter,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Name + Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              /// Actions
              Row(
                children: [
                  /// Call button
                  IconButton(
                    onPressed: phone.isNotEmpty
                        ? () => _launchPhone(phone)
                        : null,
                    icon: Icon(
                      Icons.call_rounded,
                    ),
                  ),

                  /// Email button
                  IconButton(
                    onPressed: email.isNotEmpty
                        ? () => _launchEmail(email)
                        : null,
                    icon: Icon(
                      Icons.email_outlined,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 0.2,
          ),

          const SizedBox(height: 10),

          /// 🔹 Phone Row
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                phone.isNotEmpty ? phone : "N/A",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}