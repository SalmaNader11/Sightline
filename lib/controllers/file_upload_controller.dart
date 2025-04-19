import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/document_model.dart';
import '../services/firebase_service.dart';

class FileUploadController {
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = Uuid();

  Future<DocumentModel?> uploadFile({
    required File file,
    required String uid,
    required String type, 
  }) async {
    try {
      // Get file extension & unique filename
      final fileName = _uuid.v4() + path.extension(file.path);
      final storagePath = 'documents/$uid/$fileName';

      // Upload to Firebase Storage
      final url = await _firebaseService.uploadFileToStorage(file, storagePath);

      // Create metadata
      final doc = DocumentModel(
        id: '',
        uid: uid,
        name: path.basename(file.path),
        url: url,
        type: type,
        uploadedAt: DateTime.now(),
      );

      // Save metadata to Firestore
      await _firebaseService.saveDocumentMetadata(doc);

      return doc;
    } catch (e) {
      print(' File upload failed: $e');
      return null;
    }
  }
}
