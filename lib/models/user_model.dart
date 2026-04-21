class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.createdAt,
  });
}
