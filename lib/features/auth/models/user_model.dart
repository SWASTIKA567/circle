class UserModel {
  final String id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String studentNo;
  final String? admissionNo;
  final String email;
  final String? course;
  final String? branch;
  final String? semester;
  final String? mobileNo;
  final String? dob;
  final String? bloodGroup;
  final String? fatherName;
  final String? motherName;
  final dynamic jeeRank;
  final String? highSchoolPercentage;
  final String? intermediatePercentage;
  final String? bankName;
  final String? ifscCode;
  final String? address;
  final bool isSocietyMember;
  final bool isAdmin;
  final String role;
  final String? token;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.studentNo,
    this.admissionNo,
    required this.email,
    this.course,
    this.branch,
    this.semester,
    this.mobileNo,
    this.dob,
    this.bloodGroup,
    this.fatherName,
    this.motherName,
    this.jeeRank,
    this.highSchoolPercentage,
    this.intermediatePercentage,
    this.bankName,
    this.ifscCode,
    this.address,
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
      firstName: userData['firstName'],
      lastName: userData['lastName'],
      studentNo: userData['studentNo'] ?? '',
      admissionNo: userData['admissionNo'],
      email: userData['email'] ?? '',
      course: userData['course'],
      branch: userData['branch'],
      semester: userData['semester'],
      mobileNo: userData['mobileNo'],
      dob: userData['dob'],
      bloodGroup: userData['bloodGroup'],
      fatherName: userData['fatherName'],
      motherName: userData['motherName'],
      jeeRank: userData['jeeRank'],
      highSchoolPercentage: userData['highSchoolPercentage'],
      intermediatePercentage: userData['intermediatePercentage'],
      bankName: userData['bankName'],
      ifscCode: userData['ifscCode'],
      address: userData['address'],
      isSocietyMember: userData['isSocietyMember'] ?? false,
      isAdmin: isAdminVal,
      role: roleVal,
      token: token ?? json['token'],
      createdAt: userData['createdAt'] != null
          ? DateTime.tryParse(userData['createdAt'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? studentNo,
    String? admissionNo,
    String? email,
    String? course,
    String? branch,
    String? semester,
    String? mobileNo,
    String? dob,
    String? bloodGroup,
    String? fatherName,
    String? motherName,
    dynamic jeeRank,
    String? highSchoolPercentage,
    String? intermediatePercentage,
    String? bankName,
    String? ifscCode,
    String? address,
    bool? isSocietyMember,
    bool? isAdmin,
    String? role,
    String? token,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentNo: studentNo ?? this.studentNo,
      admissionNo: admissionNo ?? this.admissionNo,
      email: email ?? this.email,
      course: course ?? this.course,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      mobileNo: mobileNo ?? this.mobileNo,
      dob: dob ?? this.dob,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      jeeRank: jeeRank ?? this.jeeRank,
      highSchoolPercentage: highSchoolPercentage ?? this.highSchoolPercentage,
      intermediatePercentage: intermediatePercentage ?? this.intermediatePercentage,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      address: address ?? this.address,
      isSocietyMember: isSocietyMember ?? this.isSocietyMember,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'studentNo': studentNo,
      if (admissionNo != null) 'admissionNo': admissionNo,
      'email': email,
      if (course != null) 'course': course,
      if (branch != null) 'branch': branch,
      if (semester != null) 'semester': semester,
      if (mobileNo != null) 'mobileNo': mobileNo,
      if (dob != null) 'dob': dob,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (fatherName != null) 'fatherName': fatherName,
      if (motherName != null) 'motherName': motherName,
      if (jeeRank != null) 'jeeRank': jeeRank,
      if (highSchoolPercentage != null) 'highSchoolPercentage': highSchoolPercentage,
      if (intermediatePercentage != null) 'intermediatePercentage': intermediatePercentage,
      if (bankName != null) 'bankName': bankName,
      if (ifscCode != null) 'ifscCode': ifscCode,
      if (address != null) 'address': address,
      'isSocietyMember': isSocietyMember,
      'isAdmin': isAdmin,
      'role': role,
      if (token != null) 'token': token,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
