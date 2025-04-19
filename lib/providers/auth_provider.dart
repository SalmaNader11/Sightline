import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  UserModel? _currentUser;
  String? _error;
  bool _loading = false;

  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _loading;
  bool get isAuthenticated => _firebaseService.currentUserId != null;

  // Initialize user on app start
  Future<void> initializeUser() async {
    final uid = _firebaseService.currentUserId;
    if (uid != null) {
      _currentUser = await _firebaseService.getUserProfile(uid);
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register(String email, String password, String username) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final cred = await _firebaseService.registerUser(email, password);
      _currentUser = await _firebaseService.getUserProfile(cred.user!.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final cred = await _firebaseService.signIn(email, password);
      _currentUser = await _firebaseService.getUserProfile(cred.user!.uid);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
