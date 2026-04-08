import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:halqati/utils/string_transformation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherDetailsCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? picProfile; // 🔹 Nullable profile image

  const TeacherDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    this.picProfile,
  });

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      debugPrint("Could not launch phone");
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri uri = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch WhatsApp");
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
          /// 🔹 Top Section (Avatar / Profile Pic + Name + Actions)
          Row(
            children: [
              /// Avatar or Network Image
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.primaryColor.withOpacity(.1),
                child: picProfile == null
                    ? Text(
                  firstLetter,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                )
                    : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: picProfile!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        firstLetter,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
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
                      name.toFirstLetterUpper(),
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
                  IconButton(
                    onPressed: phone.isNotEmpty ? () => _launchPhone(phone) : null,
                    icon: Icon(
                      Icons.call_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: email.isNotEmpty ? () => _launchWhatsApp(phone) : null,
                    icon: FaIcon(
                      FontAwesomeIcons.whatsapp,
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