class StudentStats {
  final int totalAssignments;
  final int readAssignments;
  final int completedAssignments;
  final int notCompletedAssignments;
  final int totalEvents;

  StudentStats({
    required this.totalAssignments,
    required this.readAssignments,
    required this.completedAssignments,
    required this.notCompletedAssignments,
    required this.totalEvents,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};

    return StudentStats(
      totalAssignments: stats['totalAssignments'] ?? 0,
      readAssignments: stats['readAssignments'] ?? 0,
      completedAssignments: stats['completedAssignments'] ?? 0,
      notCompletedAssignments: stats['notCompletedAssignments'] ?? 0,
      totalEvents: stats['totalEvents'] ?? 0,
    );
  }
}