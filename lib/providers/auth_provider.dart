import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestore;
  User? user;
  bool isLoading = false;
  String? errorMessage;
  late final StreamSubscription<User?> _authSubscription;

  AuthProvider(this._authService, this._firestore) {
    _authSubscription = _authService.authStateChanges().listen((event) {
      user = event;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      errorMessage = null;
      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      errorMessage = null;
      await _authService.registerWithEmail(email: email, password: password);
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final now = DateTime.now();
        final userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          displayName: firebaseUser.displayName ?? '',
          createdAt: now,
          updatedAt: now,
          settings: const {},
        );
        await _firestore.upsertUser(userModel);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      errorMessage = null;
      await _authService.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      errorMessage = null;
      await _authService.signOut();
    } catch (_) {
      errorMessage = 'Something went wrong';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}


