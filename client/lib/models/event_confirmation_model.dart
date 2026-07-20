class EventConfirmationModel {
  final int studentId;
  final String studentName;
  final String? picProfile;
  final bool? status; // true: YES, false: NO, null: PENDING

  EventConfirmationModel({
    required this.studentId,
    required this.studentName,
    this.picProfile,
    this.status,
  });

  factory EventConfirmationModel.fromJson(Map<String, dynamic> json) {
    return EventConfirmationModel(
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String,
      picProfile: json['picProfile'] as String?,
      status: _parseStatus(json['status']),
    );
  }

  static bool? _parseStatus(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
      if (value == '1') return true;
      if (value == '0') return false;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'picProfile': picProfile,
      'status': status,
    };
  }
}
