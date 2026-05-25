import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/utils/string_transformation.dart';

class StudentList extends StatelessWidget {
  final String name;
  final int totalPagesMemorized;
  final String? profileUrl; // ✅ NEW
  final VoidCallback onTap;

  const StudentList({
    super.key,
    required this.name,
    required this.totalPagesMemorized,
    required this.onTap,
    this.profileUrl,
  });

  String getInitial() {
    if (name.isEmpty) return "?";
    return name.trim()[0].toUpperCase(); // ✅ First letter
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            /// 🔥 Profile Image OR Initial
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: theme.primaryColor.withValues(alpha: 0.1),
              ),
              child: profileUrl != null && profileUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  profileUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitial(theme),
                ),
              )
                  : _buildInitial(theme),
            ),

            const SizedBox(width: 10),

            /// 🔹 Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toFirstLetterUpper(),
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  "${"memorized_juz".tr()}: $totalPagesMemorized/30",
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Initial Avatar
  Widget _buildInitial(ThemeData theme) {
    return Center(
      child: Text(
        getInitial(),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}