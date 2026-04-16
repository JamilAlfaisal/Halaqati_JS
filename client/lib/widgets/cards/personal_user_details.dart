import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/utils/helper_methods.dart';

class PersonalUserDetails extends StatelessWidget {
  final String email;
  final String phone;
  final DateTime? dob;

  const PersonalUserDetails({
    super.key,
    required this.phone,
    required this.email,
    this.dob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildRow({
      required IconData icon,
      required String value,
    }) {
      return Container(
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
            Icon(
              icon,
              size: 20,
              color: theme.primaryColor,
            ),
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
          ],
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

          const SizedBox(height: 14),

          /// 🔹 Email
          buildRow(
            icon: Icons.alternate_email_outlined,
            value: email.isNotEmpty ? email : "undefined".tr(),
          ),

          const SizedBox(height: 10),

          /// 🔹 Phone
          buildRow(
            icon: Icons.phone_android_rounded,
            value: phone.isNotEmpty ? phone : "undefined".tr(),
          ),

          const SizedBox(height: 10),

          /// 🔹 DOB
          buildRow(
            icon: Icons.date_range_sharp,
            value: dob != null
                ? HelperMethods.formatDate(dob)
                : "undefined".tr(),
          ),
        ],
      ),
    );
  }
}