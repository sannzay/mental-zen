import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isValidatingUser = false;
  late final StreamSubscription<User?> _authSubscription;

  AuthProvider(this._authService, this._firestore) {
    _authSubscription = _authService.authStateChanges().listen((event) async {
      user = event;
      if (event != null && !_isValidatingUser) {
        await _validateUserDocument(event.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _validateUserDocument(String uid) async {
    _isValidatingUser = true;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _authService.signOut();
        user = null;
      }
    } catch (_) {
      await _authService.signOut();
      user = null;
    } finally {
      _isValidatingUser = false;
    }
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
        final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        if (!doc.exists) {
          await _authService.signOut();
          errorMessage = 'Failed to create user profile. Please try again.';
        }
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _authService.signOut();
      }
    } catch (e) {
      errorMessage = 'Something went wrong: ${e.toString()}';
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _authService.signOut();
      }
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


