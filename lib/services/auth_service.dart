import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Invalid email');
    }
    if (password.length < 8) {
      throw FirebaseAuthException(code: 'weak-password', message: 'Password too short');
    }
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    if (!_isValidEmail(email)) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Invalid email');
    }
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  bool _isValidEmail(String email) {
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return pattern.hasMatch(email);
  }
}


