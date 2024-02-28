class Doc {
  final String fileName;
  final String assignmentTitle;
  final String assigmentDescription;
  final String docId;
  final String type;
  final String fileUrl;
  final String prediction;
  final String createdAt;
  final List<String> tags;
  Doc({
    required this.fileName,
    required this.assignmentTitle,
    required this.assigmentDescription,
    required this.docId,
    required this.type,
    required this.fileUrl,
    required this.prediction,
    required this.createdAt,
    required this.tags,
  });

  Doc copyWith({
    String? fileName,
    String? assignmentTitle,
    String? assigmentDescription,
    String? docId,
    String? type,
    String? fileUrl,
    String? prediction,
    String? createdAt,
    List<String>? tags,
  }) {
    return Doc(
      fileName: fileName ?? this.fileName,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      assigmentDescription: assigmentDescription ?? this.assigmentDescription,
      docId: docId ?? this.docId,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      prediction: prediction ?? this.prediction,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileName': fileName,
      'assignmentTitle': assignmentTitle,
      'assigmentDescription': assigmentDescription,
      'docId': docId,
      'type': type,
      'fileUrl': fileUrl,
      'prediction': prediction,
      'createdAt': createdAt,
      'tags': tags,
    };
  }

  factory Doc.fromMap(Map<String, dynamic> map) {
    return Doc(
      fileName: map['fileName'] as String,
      assignmentTitle: map['assignmentTitle'] as String,
      assigmentDescription: map['assigmentDescription'] as String,
      docId: map['docId'] as String,
      type: map['type'] as String,
      fileUrl: map['fileUrl'] as String,
      prediction: map['prediction'] as String,
      createdAt: map['createdAt'] as String,
      tags: List<String>.from(
        (map['tags']),
      ),
    );
  }
}
