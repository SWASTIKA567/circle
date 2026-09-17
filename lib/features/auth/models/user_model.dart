class UserModel {
  final String id;
  final String name;
  final String studentNo;
  final String email;
  final bool isSocietyMember;
  final String? token;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.studentNo,
    required this.email,
    this.isSocietyMember = false,
    this.token,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final userData = json['user'] ?? json;
    return UserModel(
      id: userData['id'] ?? userData['_id'] ?? '',
      name: userData['name'] ?? '',
      studentNo: userData['studentNo'] ?? '',
      email: userData['email'] ?? '',
      isSocietyMember: userData['isSocietyMember'] ?? false,
      token: token ?? json['token'],
      createdAt: userData['createdAt'] != null
          ? DateTime.tryParse(userData['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentNo': studentNo,
      'email': email,
      'isSocietyMember': isSocietyMember,
      if (token != null) 'token': token,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
