class AttendanceSubjectModel {
  final String subjectCode;
  final String subjectName;
  final String facultyName;
  final int totalClasses;
  final int present;
  final int absent;
  final double percentage;
  final int safeBunk;
  final int requiredToAttend;
  final String status; // 'safe', 'warning', 'critical'

  AttendanceSubjectModel({
    required this.subjectCode,
    required this.subjectName,
    required this.facultyName,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.percentage,
    required this.safeBunk,
    required this.requiredToAttend,
    required this.status,
  });

  factory AttendanceSubjectModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSubjectModel(
      subjectCode: json['subjectCode']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? 'Subject',
      facultyName: json['facultyName']?.toString() ?? '',
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      safeBunk: (json['safeBunk'] as num?)?.toInt() ?? 0,
      requiredToAttend: (json['requiredToAttend'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'safe',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'facultyName': facultyName,
      'totalClasses': totalClasses,
      'present': present,
      'absent': absent,
      'percentage': percentage,
      'safeBunk': safeBunk,
      'requiredToAttend': requiredToAttend,
      'status': status,
    };
  }
}

class AttendanceDataModel {
  final double overallPercentage;
  final int totalHeld;
  final int totalPresent;
  final int totalAbsent;
  final int overallSafeBunk;
  final int overallRequiredToAttend;
  final String status;
  final List<AttendanceSubjectModel> subjects;
  final DateTime? lastSync;
  final bool isFromCache;

  AttendanceDataModel({
    required this.overallPercentage,
    required this.totalHeld,
    required this.totalPresent,
    required this.totalAbsent,
    required this.overallSafeBunk,
    required this.overallRequiredToAttend,
    required this.status,
    required this.subjects,
    this.lastSync,
    this.isFromCache = false,
  });

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json, {bool isFromCache = false}) {
    final subList = json['subjects'] as List? ?? [];
    return AttendanceDataModel(
      overallPercentage: (json['overallPercentage'] as num?)?.toDouble() ?? 0.0,
      totalHeld: (json['totalHeld'] as num?)?.toInt() ?? 0,
      totalPresent: (json['totalPresent'] as num?)?.toInt() ?? 0,
      totalAbsent: (json['totalAbsent'] as num?)?.toInt() ?? 0,
      overallSafeBunk: (json['overallSafeBunk'] as num?)?.toInt() ?? 0,
      overallRequiredToAttend: (json['overallRequiredToAttend'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'safe',
      subjects: subList.map((e) => AttendanceSubjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      lastSync: json['lastSync'] != null ? DateTime.tryParse(json['lastSync'].toString()) : null,
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallPercentage': overallPercentage,
      'totalHeld': totalHeld,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'overallSafeBunk': overallSafeBunk,
      'overallRequiredToAttend': overallRequiredToAttend,
      'status': status,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      if (lastSync != null) 'lastSync': lastSync!.toIso8601String(),
    };
  }
}
