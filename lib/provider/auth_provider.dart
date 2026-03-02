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
  String get userName => _userData?["username"] ?? "";

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

  void _initialize() {
    _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;

      if (_user != null) {
        final doc =
            await _firestore.collection("users").doc(_user!.uid).get();
        _userData = doc.exists ? doc.data() : null;
      } else {
        _userData = null;
      }

      _initialized = true;
      notifyListeners();
    });
  }

  // ===========================
  // GOOGLE SIGN-IN (LOGIN ONLY)
  // ===========================
  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      // FORCE ACCOUNT PICKER EVERY TIME
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) return "Login failed";

      final doc =
          await _firestore.collection("users").doc(user.uid).get();

      // BLOCK UNREGISTERED USERS
      if (!doc.exists) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        return "Account not registered. Please sign up first.";
      }

      _user = user;
      _userData = doc.data();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ===========================
  // EMAIL SIGN-UP
  // ===========================
  Future<String?> signUpWithEmail(
      String username, String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  // ===========================
  // LOGIN WITH USERNAME
  // ===========================
  Future<String?> loginWithUsername(
      String username, String password) async {
    _setLoading(true);
    try {
      final query = await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return "Username not found";

      final email = query.docs.first.data()["email"];
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = cred.user;
      _userData = query.docs.first.data();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ===========================
  // FORGOT PASSWORD
  // ===========================
  Future<String?> sendPasswordResetByUsername(String username) async {
    try {
      final query = await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return "Username not found";

      final email = query.docs.first.data()["email"];
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ===========================
  // LOGOUT
  // ===========================
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
