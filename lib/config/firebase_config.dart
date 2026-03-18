import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import your Firebase options
import '../firebase_options.dart';

class FirebaseConfig {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      await _setupFirestore();
      
      // Only setup notifications on supported platforms
      if (!kIsWeb || (kIsWeb && await _isWebNotificationSupported())) {
        await _setupNotifications();
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Check if web notifications are supported
  static Future<bool> _isWebNotificationSupported() async {
    try {
      return await _messaging.isSupported();
    } catch (e) {
      return false;
    }
  }

  // Firestore Collections
  static CollectionReference<Map<String, dynamic>> get usersCollection => 
      _firestore.collection('users');
  
  static CollectionReference<Map<String, dynamic>> get jobsCollection => 
      _firestore.collection('jobs');
  
  static CollectionReference<Map<String, dynamic>> get applicationsCollection => 
      _firestore.collection('applications');
  
  static CollectionReference<Map<String, dynamic>> get resumesCollection => 
      _firestore.collection('resumes');
  
  static CollectionReference<Map<String, dynamic>> get messagesCollection => 
      _firestore.collection('messages');
  
  static CollectionReference<Map<String, dynamic>> get conversationsCollection => 
      _firestore.collection('conversations');
  
  static CollectionReference<Map<String, dynamic>> get notificationsCollection => 
      _firestore.collection('notifications');
  
  static CollectionReference<Map<String, dynamic>> get companiesCollection => 
      _firestore.collection('companies');
  
  static CollectionReference<Map<String, dynamic>> get assessmentsCollection => 
      _firestore.collection('assessments');
  
  static CollectionReference<Map<String, dynamic>> get templatesCollection => 
      _firestore.collection('templates');

  // Firebase Storage Paths
  static String getProfileImagesPath(String userId) => 
      'users/$userId/profile.jpg';
  
  static String getResumesPath(String userId, String resumeId) => 
      'users/$userId/resumes/$resumeId.pdf';
  
  static String getCompanyLogosPath(String companyId) => 
      'companies/$companyId/logo.jpg';
  
  static String getJobAttachmentsPath(String jobId, String fileName) => 
      'jobs/$jobId/$fileName';
  
  static String getChatAttachmentsPath(String conversationId, String fileName) => 
      'chats/$conversationId/$fileName';

  // Firestore Settings
  static Future<void> _setupFirestore() async {
    try {
      // Only set cache settings for non-web platforms
      if (!kIsWeb) {
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    } catch (e) {
      print('Error setting up Firestore: $e');
    }
  }

  // Notification Setup
  static Future<void> _setupNotifications() async {
    try {
      // Request permissions (handled differently on web)
      NotificationSettings settings;
      
      if (kIsWeb) {
        // For web, we need to handle permissions differently
        settings = await _messaging.requestPermission();
      } else {
        // For mobile platforms
        settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        String? token = await _messaging.getToken();
        print('FCM Token: $token');

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          // Update token in Firestore
          _updateFCMToken(newToken);
        });

        // Update token for current user
        await _updateFCMToken(token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.notification?.title}');
        // You can add custom handling here
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.messageId}');
        // Handle navigation based on notification data
      });

    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling background message: ${message.messageId}");
    print("Message data: ${message.data}");
    
    // You can add custom background handling here
    // For example, save to local database or update UI
  }

  static Future<void> _updateFCMToken(String? token) async {
    if (token == null) return;
    
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'fcmToken': token,
          'lastActive': FieldValue.serverTimestamp(),
          'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Firebase Auth State
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  static User? get currentUser => _auth.currentUser;

  // Sign Out
  static Future<void> signOut() async {
    try {
      // Clear FCM token on sign out for non-web platforms
      if (!kIsWeb && currentUser != null) {
        await usersCollection.doc(currentUser!.uid).update({
          'fcmToken': FieldValue.delete(),
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Firestore Helpers
  static Future<void> setDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await collection.doc(docId).set(data);
    } catch (e) {
      print('Error setting document: $e');
      rethrow;
    }
  }

  static Future<void> updateDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await collection.doc(docId).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  static Future<void> deleteDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) async {
    try {
      await collection.doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String docId,
  }) async {
    try {
      return await collection.doc(docId).get();
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  static Query<Map<String, dynamic>> queryCollection({
    required CollectionReference<Map<String, dynamic>> collection,
    String? field,
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isGreaterThan,
    dynamic arrayContains,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection;
    
    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (arrayContains != null) {
        query = query.where(field, arrayContains: arrayContains);
      }
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query;
  }

  // Batch Operations
  static Future<void> runBatch(List<Function(WriteBatch batch)> operations) async {
    try {
      final batch = _firestore.batch();
      for (var operation in operations) {
        operation(batch);
      }
      await batch.commit();
    } catch (e) {
      print('Error running batch: $e');
      rethrow;
    }
  }

  // Transaction
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction,
  ) async {
    try {
      return await _firestore.runTransaction(transactionFunction);
    } catch (e) {
      print('Error running transaction: $e');
      rethrow;
    }
  }

  // Storage Operations (with web support)
  static Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  static Future<String> uploadFileFromPath({
    required String path,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file from path: $e');
      rethrow;
    }
  }

  // Upload file from bytes (good for web)
  static Future<String> uploadFileFromBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType ?? 'application/octet-stream',
      );
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file from bytes: $e');
      rethrow;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  static Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  // Upload file with progress tracking (works on all platforms)
  static Future<String> uploadFileWithProgress({
    required String path,
    required dynamic file, // Can be File or Uint8List
    required Function(double progress) onProgress,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      late UploadTask task;
      
      if (file is File) {
        // Mobile upload
        task = ref.putFile(file);
      } else if (file is Uint8List) {
        // Web upload
        final metadata = SettableMetadata(
          contentType: contentType ?? 'application/octet-stream',
        );
        task = ref.putData(file, metadata);
      } else {
        throw Exception('Unsupported file type');
      }
      
      // Listen to progress events
      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file with progress: $e');
      rethrow;
    }
  }

  // Upload image data (works on all platforms)
  static Future<String> uploadImageData({
    required String path,
    required Uint8List imageData,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      await ref.putData(imageData, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image data: $e');
      rethrow;
    }
  }

  // Get file metadata
  static Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      print('Error getting file metadata: $e');
      rethrow;
    }
  }

  // Update file metadata
  static Future<void> updateFileMetadata({
    required String path,
    required SettableMetadata metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.updateMetadata(metadata);
    } catch (e) {
      print('Error updating file metadata: $e');
      rethrow;
    }
  }

  // List files in a directory
  static Future<List<Reference>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      print('Error listing files: $e');
      rethrow;
    }
  }

  // Get file size
  static Future<int?> getFileSize(String path) async {
    try {
      final metadata = await getFileMetadata(path);
      return metadata.size;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  // Check if file exists
  static Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to handle platform-specific operations
  static bool get isWeb => kIsWeb;
  
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
}