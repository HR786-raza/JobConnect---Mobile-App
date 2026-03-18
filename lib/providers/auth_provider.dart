import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // Removed unused _firestore and _storage declarations

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  

  // Listen to auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _setLoading(true);
      final doc = await FirebaseConfig.usersCollection.doc(uid).get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // Create new user document if it doesn't exist
        _currentUser = UserModel(
          uid: uid,
          email: _auth.currentUser?.email ?? '',
          displayName: _auth.currentUser?.displayName,
          photoURL: _auth.currentUser?.photoURL,
          userType: UserType.employee, // Default to employee
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await saveUserData(_currentUser!);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await FirebaseConfig.usersCollection.doc(user.uid).set(user.toFirestore());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error saving user data: $e';
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      if (_currentUser != null) {
        await FirebaseConfig.usersCollection.doc(_currentUser!.uid).update(updates);
        await _loadUserData(_currentUser!.uid);
      }
    } catch (e) {
      _errorMessage = 'Error updating user data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!.uid);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Google sign in failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.token,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          await _loadUserData(userCredential.user!.uid);
          return true;
        }
      }

      return false;
    } catch (e) {
      _errorMessage = 'Facebook sign in failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!.uid);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Email sign in failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update profile
        await userCredential.user!.updateDisplayName(name);

        // Create user document
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: name,
          userType: userType,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await saveUserData(newUser);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user type
  Future<void> updateUserType(UserType userType) async {
    if (_currentUser != null) {
      await updateUserData({'userType': userType.toString().split('.').last});
    }
  }

  // Update profile image
  Future<String?> updateProfileImage(File imageFile) async {
    try {
      _setLoading(true);
      
      if (_currentUser == null) return null;

      final path = FirebaseConfig.getProfileImagesPath(_currentUser!.uid);
      final downloadUrl = await FirebaseConfig.uploadFile(
        path: path,
        file: imageFile,
      );

      await updateUserData({'photoURL': downloadUrl});
      
      // Update Firebase Auth profile
      await _auth.currentUser?.updatePhotoURL(downloadUrl);
      
      return downloadUrl;
    } catch (e) {
      _errorMessage = 'Failed to update profile image: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive() async {
    if (_currentUser != null) {
      await FirebaseConfig.usersCollection.doc(_currentUser!.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      _errorMessage = 'Failed to send verification email: $e';
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}