

import 'package:easy_localization/easy_localization.dart';

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
    return DateFormat(format).format(date);
  }


}