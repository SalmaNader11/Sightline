import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_data.dart';
import '../models/document_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerUser(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'createdAt': Timestamp.now(),
      'lastLogin': Timestamp.now(),
      'preferences': {
        'darkMode': false,
        'notifications': true,
        'ttsSpeed': 1.0,
        'ttsPitch': 1.0,
        'ttsLanguage': 'en-US',
        'speakAsYouType': false,
      },
    });

    return userCredential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).update({
      'lastLogin': Timestamp.now(),
    });

    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<Map<String, dynamic>?> getUserPreferences(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['preferences'];
  }

  Future<void> updateUserPreferences(String uid, Map<String, dynamic> newPrefs) async {
    await _firestore.collection('users').doc(uid).update({
      'preferences': newPrefs,
    });
  }

  Future<void> updateTTSPreferences({
    required String uid,
    required double speed,
    required double pitch,
    required String language,
    required bool speakAsYouType,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'preferences.ttsSpeed': speed,
      'preferences.ttsPitch': pitch,
      'preferences.ttsLanguage': language,
      'preferences.speakAsYouType': speakAsYouType,
    });
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> reauthenticateAndChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in');
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> uploadFileToStorage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveDocumentMetadata(DocumentModel doc) async {
    await _firestore.collection('documents').add(doc.toMap());
  }
}
