import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:halqati/models/teacher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/utils/string_transformation.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:shimmer/shimmer.dart';

class TeacherProfile extends StatelessWidget {
  final Teacher? teacher;

  const TeacherProfile({super.key, required this.teacher});

  String getInitial() {
    final name = teacher?.name ?? "";
    if (name.trim().isEmpty) return "?";
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = teacher?.picProfile ?? "";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          /// 🔥 Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.primaryColor.withOpacity(.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,

                /// 🔹 Loading shimmer
                placeholder: (context, url) =>
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),

                /// 🔥 Fallback to initial instead of broken icon
                errorWidget: (context, url, error) =>
                    _buildInitial(theme),
              )
                  : _buildInitial(theme),
            ),
          ),

          const SizedBox(width: 14),

          /// 🔹 Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher?.name.toFirstLetterUpper() ??
                      "undefined".tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "ID: #${teacher?.id ?? '-'}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 6),

                /// 🔹 Optional role badge
                CustomLabel(text: "teacher".tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔤 Initial Avatar
  Widget _buildInitial(ThemeData theme) {
    return Center(
      child: Text(
        getInitial(),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}