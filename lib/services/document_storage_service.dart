import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document_model.dart';

class DocumentStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///  Upload using file picker + save to Firestore
  Future<void> uploadFile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'txt', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final docId = _firestore.collection('documents').doc().id;

      // Upload to Firebase Storage
      final downloadUrl = await uploadRawFile(file, user.uid, fileName);

      // Create document metadata
      final document = DocumentModel(
        id: docId,
        userId: user.uid,
        fileName: fileName,
        url: downloadUrl,
        uploadedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('documents').doc(docId).set(document.toMap());
    }
  }

  ///  Upload file directly and return download URL (reusable)
  Future<String> uploadRawFile(File file, String userId, String fileName) async {
    try {
      final ref = _storage.ref().child('documents/$userId/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String userId, String fileName) async {
    try {
      final ref = _storage.ref().child('documents/$userId/$fileName');
      await ref.delete();
    } catch (e) {
      print('Delete failed or file not found: $e');
    }
  }
}
