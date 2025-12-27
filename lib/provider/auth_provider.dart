import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? _user;
  User? get user => _user;

  Map<String, dynamic>? _userData;
  String get userName => _userData?["name"] ?? "";

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _initialized = false;
  bool get initialized => _initialized;

  AuthProvider() {
    _initialize();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Initialize Firebase auth listener
  void _initialize() {
    _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;

      if (_user != null) {
        final doc = await _firestore.collection("users").doc(_user!.uid).get();
        _userData = doc.exists ? doc.data() : null;
      } else {
        _userData = null;
      }

      _initialized = true; // <-- ensures wrapper waits for auth state
      notifyListeners();
    });
  }

  // -------------------
  // GOOGLE SIGN-IN
  // -------------------
  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Save user in Firestore if first-time login
      final docRef = _firestore.collection("users").doc(_user!.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set({
          "name": _user!.displayName ?? "User",
          "email": _user!.email,
          "createdAt": DateTime.now(),
        });
      }

      final freshDoc = await docRef.get();
      _userData = freshDoc.data();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // -------------------
  // EMAIL SIGN-UP
  // -------------------
  Future<String?> signUpWithEmail(String username, String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.updateDisplayName(username);

      await _firestore.collection("users").doc(cred.user!.uid).set({
        "username": username,
        "email": email,
        "createdAt": DateTime.now(),
      });

      _user = cred.user;
      _userData = {"username": username, "email": email};

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  // -------------------
  // EMAIL LOGIN USING USERNAME
  // -------------------
  Future<String?> loginWithUsername(String username, String password) async {
    _setLoading(true);
    try {
      final query = await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return "Username not found";

      final email = query.docs.first.data()["email"] as String?;
      if (email == null) return "No email associated with this username";

      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      _user = cred.user;
      _userData = query.docs.first.data();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

// -------------------
// FORGOT PASSWORD (USERNAME BASED)
// -------------------
Future<String?> sendPasswordResetByUsername(String username) async {
  try {
    final query = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return "Username not found";
    }

    final email = query.docs.first.data()["email"] as String?;
    if (email == null || email.isEmpty) {
      return "No email associated with this username";
    }

    await _auth.sendPasswordResetEmail(email: email);
    return null; // success
  } on FirebaseAuthException catch (e) {
    return e.message;
  } catch (e) {
    return "Something went wrong. Try again.";
  }
}



  // -------------------
  // LOGOUT
  // -------------------
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      _userData = null;
    } finally {
      _setLoading(false);
    }
  }
}
