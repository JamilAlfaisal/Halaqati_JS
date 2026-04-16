import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetails extends StatelessWidget {
  final String email;
  final String phone;
  final DateTime? dob;

  const UserDetails({
    super.key,
    required this.phone,
    required this.email,
    this.dob,
  });

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied to clipboard"),
        duration: const Duration(seconds: 1),
      ),
    );
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

    Widget buildRow({
      required dynamic icon,
      required String value,
      VoidCallback? onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (icon is IconData)
                  Icon(
                    icon,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                if (icon is FaIconData)
                  FaIcon(icon, color: theme.primaryColor,),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (onTap != null)
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.grey[500],
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Section T

          const SizedBox(height: 14),

          /// 🔹 Email
          buildRow(
            icon: Icons.alternate_email_outlined,
            value: email.isNotEmpty ? email : "N/A",
            onTap: email.isNotEmpty
                ? () {
              _launchEmail(email);
            }
                : null,
          ),

          const SizedBox(height: 10),

          /// 🔹 Phone

          buildRow(
            icon: Icons.call,
            value: phone.isNotEmpty ? phone : "N/A",
            onTap: phone.isNotEmpty
                ? () {
              _launchPhone(phone);
            }
                : null,
          ),

          const SizedBox(height: 10),

          buildRow(
            icon: FontAwesomeIcons.whatsapp,
            value: phone.isNotEmpty ? phone : "N/A",
            onTap: phone.isNotEmpty
                ? () {
              _launchWhatsApp(phone);
            }
                : null,
          ),

          const SizedBox(height: 10),

          /// 🔹 DOB (copy on tap)
          buildRow(
            icon: Icons.date_range_sharp,
            value: dob != null
                ? HelperMethods.formatDate(dob)
                : "not_defined".tr(),
            onTap: dob != null
                ? () {
              _copy(
                context,
                HelperMethods.formatDate(dob),
              );
            }
                : null,
          ),
        ],
      ),
    );
  }
}