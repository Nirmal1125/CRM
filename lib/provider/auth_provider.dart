import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  AuthProvider();

  void initialize() {
    _auth.authStateChanges().listen(_authStateChanged);
  }

  Future<void> _authStateChanged(User? firebaseUser) async {
    _user = firebaseUser;

    if (firebaseUser != null) {
      // fetch user data from Firestore
      final doc = await _firestore.collection("users").doc(firebaseUser.uid).get();
      if (doc.exists) _userData = doc.data();
    }

    notifyListeners();
  }

  // GOOGLE SIGN-IN / SIGN-UP
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Save user to Firestore if first time
      final docRef = _firestore.collection("users").doc(userCredential.user!.uid);

      if (!(await docRef.get()).exists) {
        await docRef.set({
          "name": userCredential.user!.displayName ?? "User",
          "email": userCredential.user!.email,
          "createdAt": DateTime.now(),
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // EMAIL SIGN-UP
 // SIGN UP WITH EMAIL + USERNAME
Future<String?> signUpWithEmail(String username, String email, String password) async {
  try {
    _isLoading = true;
    notifyListeners();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.updateDisplayName(username);

    // Save user in Firestore
    await _firestore.collection("users").doc(cred.user!.uid).set({
      "username": username,
      "email": email,
      "createdAt": DateTime.now(),
    });

    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // EMAIL LOGIN
  Future<String?> loginWithUsername(String username, String password) async {
  try {
    _isLoading = true;
    notifyListeners();

    // Find email associated with username
    final query = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return "Username not found";
    }

    final email = query.docs.first.data()["email"];

    // Now sign in normally with email + password
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _userData = query.docs.first.data();
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
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
