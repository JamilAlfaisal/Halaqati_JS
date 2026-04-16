import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/utils/string_transformation.dart';

class StudentProfileLeft extends StatelessWidget {
  final Student student;

  const StudentProfileLeft({
    super.key,
    required this.student,
  });

  String getInitial() {
    final name = student.name;
    if (name.trim().isEmpty) return "?";
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageUrl = student.picProfile; // 🔥 assuming exists

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
      child: Row(
        children: [
          /// 🔥 Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.1),
            ),
            child: ClipOval(
              child: (imageUrl.isNotEmpty)
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitial(theme),
              )
                  : _buildInitial(theme),
            ),
          ),

          const SizedBox(width: 16),

          /// 🔹 Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name.toFirstLetterUpper(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "ID: #${student.id}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${"juz".tr()}: ${student.memorizedJuz.length}/30",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${"registered".tr()}: ${HelperMethods.formatDate(student.registeredAt)}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
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