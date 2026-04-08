class AttendanceStats {
  final String studentId;
  final String name;
  final int attendanceCount;

  AttendanceStats({
    required this.studentId,
    required this.name,
    required this.attendanceCount,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      studentId: json['studentId'].toString(),
      name: json['name'] ?? "",
      attendanceCount: json['attendanceCount'] ?? 0,
    );
  }
}