

class Teacher{
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  // final int? studentCount;

  Teacher({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.dateOfBirth,
    // this.studentCount
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
    };
  }

  Teacher copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}