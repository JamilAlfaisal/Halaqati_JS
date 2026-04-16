class AboutUs {
  final int id;
  final String arabicContent;
  final String englishContent;
  final String? linkedInUrl;
  final String? contactPhone;
  final String version;

  AboutUs({
    required this.id,
    required this.arabicContent,
    required this.englishContent,
    this.linkedInUrl,
    this.contactPhone,
    required this.version,
  });

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    return AboutUs(
      id: json['id'] as int,
      arabicContent: json['arabicContent'] as String,
      englishContent: json['englishContent'] as String,
      linkedInUrl: json['linkedInUrl'] as String?,
      contactPhone: json['contactPhone'] as String?,
      version: json['version'] ?? '1.0.0',
    );
  }

  // Method to convert the object back to JSON (useful if you add an Admin edit feature)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicContent': arabicContent,
      'englishContent': englishContent,
      'linkedInUrl': linkedInUrl,
      'contactPhone': contactPhone,
      'version': version,
    };
  }
}