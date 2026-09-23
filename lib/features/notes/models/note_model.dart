class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String unit;
  final String author;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String pages;
  final String status;
  final bool isApproved;
  final DateTime? createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.semester,
    required this.unit,
    required this.author,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.pages,
    this.status = 'pending',
    this.isApproved = false,
    this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] ?? (json['isApproved'] == true ? 'approved' : 'pending');
    final isApprovedVal = json['isApproved'] == true || statusVal == 'approved';

    return NoteModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled Note',
      subject: json['subject'] ?? 'General',
      semester: json['semester'] ?? 'Semester 1',
      unit: json['unit'] ?? 'Unit 1',
      author: json['author'] ?? 'Anonymous',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      pages: json['pages'] ?? 'PDF',
      status: statusVal,
      isApproved: isApprovedVal,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'semester': semester,
      'unit': unit,
      'author': author,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'pages': pages,
      'status': status,
      'isApproved': isApproved,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
