import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;         
  final String uid;        
  final String name;       
  final String url;        
  final String type;       
  final DateTime uploadedAt;

  DocumentModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'unknown',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'url': url,
      'type': type,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  @override
  String toString() {
    return 'DocumentModel(name: $name, type: $type, uploadedAt: $uploadedAt)';
  }
}
