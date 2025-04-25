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
    String? processedText,
    String? audioPath,
    String? styledPath,
  }) async {
    try {
      final fileName = _uuid.v4() + path.extension(file.path);
      final storagePath = 'documents/$uid/$fileName';

      final url = await _firebaseService.uploadFileToStorage(file, storagePath);
      final docId = _firebaseService.firestore.collection('documents').doc().id;

      final doc = DocumentModel(
        id: docId,
        userId: uid,
        fileName: path.basename(file.path),
        url: url,
        fileType: type,
        uploadedAt: DateTime.now(),
        originalFilePath: storagePath,
        processedText: processedText,
        audioPath: audioPath,
        styledPath: styledPath,
        status: 'processed',
      );

      await _firebaseService.firestore.collection('documents').doc(docId).set(doc.toMap());
      return doc;
    } catch (e) {
      print('File upload failed: $e');
      return null;
    }
  }

  /// Upload file and save metadata (for compatibility with older usages)
  Future<DocumentModel?> uploadFileAndSaveMetadata({
    required File file,
    required String uid,
    required String type,
    String? processedText,
    String? audioPath,
    String? styledPath,
  }) async {
    // This simply calls uploadFile (for API compatibility)
    return await uploadFile(
      file: file,
      uid: uid,
      type: type,
      processedText: processedText,
      audioPath: audioPath,
      styledPath: styledPath,
    );
  }
}
