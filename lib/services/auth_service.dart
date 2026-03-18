import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        return await _getOrCreateUser(userCredential.user!);
      }

      return null;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<UserModel?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = 
            FacebookAuthProvider.credential(result.accessToken!.token);

        final UserCredential userCredential = 
            await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          return await _getOrCreateUser(userCredential.user!);
        }
      }

      return null;
    } catch (e) {
      print('Facebook sign in error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        return await _getUserData(userCredential.user!.uid);
      }

      return null;
    } catch (e) {
      print('Email sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required UserType userType,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

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

        await _createUserData(newUser);
        return newUser;
      }

      return null;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // Get or create user
  Future<UserModel?> _getOrCreateUser(User firebaseUser) async {
    try {
      final userDoc = await FirebaseConfig.usersCollection
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          userType: UserType.employee,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await _createUserData(newUser);
        return newUser;
      }
    } catch (e) {
      print('Get or create user error: $e');
      return null;
    }
  }

  // Get user data
  Future<UserModel?> _getUserData(String uid) async {
    try {
      final doc = await FirebaseConfig.usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Create user data
  Future<void> _createUserData(UserModel user) async {
    try {
      await FirebaseConfig.usersCollection
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      print('Create user data error: $e');
      rethrow;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseConfig.usersCollection.doc(uid).update(data);
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String uid) async {
    try {
      await FirebaseConfig.usersCollection.doc(uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update last active error: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseConfig.usersCollection.doc(user.uid).delete();
        
        // Delete user authentication
        await user.delete();
      }
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Send email verification error: $e');
      rethrow;
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Update password error: $e');
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      print('Update email error: $e');
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Refresh user
  Future<void> refreshUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Refresh user error: $e');
    }
  }

  // Get ID token
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Get ID token error: $e');
      return null;
    }
  }
}