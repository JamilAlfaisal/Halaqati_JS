abstract class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final DateTime dob;
  final DateTime createdAt;
  final String picProfile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dob,
    required this.phone,
    required this.createdAt,
    required this.picProfile,
  });
}
