import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? user;
  bool isLoading = false;
  String? errorMessage;
  late final StreamSubscription<User?> _authSubscription;

  AuthProvider(this._authService) {
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


