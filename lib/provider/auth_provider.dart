import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Correct constructor with scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen(_authStateChanged);
  }

  void _authStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    notifyListeners();
  }

  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn(); // signIn() exists in 7.x

      if (googleUser == null) return "Google Sign-In cancelled";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken removed because getter may not exist
      );

      await _auth.signInWithCredential(credential);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<String?> signInWithEmail(String email, String password) async {
  try {
    _isLoading = true;
    notifyListeners();

    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<String?> signUpWithEmail(String name, String email, String password) async {
  try {
    _isLoading = true;
    notifyListeners();

    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    // store user name
    await _auth.currentUser!.updateDisplayName(name);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
