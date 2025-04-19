import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_data.dart';

class RegistrationResult {
  final UserData? userData;
  final String? error;

  RegistrationResult({this.userData, this.error});
}

class RegistrationController {
  final FirebaseService _firebaseService = FirebaseService();

  Future<RegistrationResult> registerUser(String email, String password) async {
    try {
      final userCredential = await _firebaseService.registerUser(email, password);
      final uid = userCredential.user!.uid;

      final userData = await _firebaseService.getUserProfile(uid);
      return RegistrationResult(userData: userData);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }
      return RegistrationResult(error: message);
    } catch (e) {
      return RegistrationResult(error: 'Unexpected error occurred. Try again.');
    }
  }
}
