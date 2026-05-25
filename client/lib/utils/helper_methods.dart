

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HelperMethods {
  static String getTerms(Map<String, dynamic> json, List<String> terms) {
    final foundKey = terms.firstWhere(
          (term) => json[term] != null,
      orElse: () => "",
    );
    return json[foundKey]?.toString() ?? "";
  }
  static DateTime parseDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? "") ?? DateTime.now();
  }

  static String formatDate(DateTime? date, {String format = 'yyyy-MM-dd'}) {
    if (date == null) return "";
    DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
    return DateFormat(format, 'en').format(date);
  }


  static Color getPageColor(DateTime? reviewDate) {
    if (reviewDate == null) return Colors.grey.shade300; // Not memorized

    final daysSince = DateTime.now().difference(reviewDate).inDays;

    // 0 days = Pure Blue, 7+ days = Pure Yellow
    double ratio = (daysSince / 7).clamp(0.0, 1.0);
    return Color.lerp(Colors.blue, Colors.yellow.shade700, ratio)!;
  }

}