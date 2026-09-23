class UserModel {
  final String id;
  final String name;
  final String studentNo;
  final String email;
  final bool isSocietyMember;
  final bool isAdmin;
  final String role;
  final String? token;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.studentNo,
    required this.email,
    this.isSocietyMember = false,
    this.isAdmin = false,
    this.role = 'student',
    this.token,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final userData = json['user'] ?? json;
    final roleVal = userData['role'] ?? (userData['isAdmin'] == true ? 'admin' : 'student');
    final isAdminVal = userData['isAdmin'] == true || roleVal == 'admin';

    return UserModel(
      id: userData['id'] ?? userData['_id'] ?? '',
      name: userData['name'] ?? '',
      studentNo: userData['studentNo'] ?? '',
      email: userData['email'] ?? '',
      isSocietyMember: userData['isSocietyMember'] ?? false,
      isAdmin: isAdminVal,
      role: roleVal,
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
      'isAdmin': isAdmin,
      'role': role,
      if (token != null) 'token': token,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
