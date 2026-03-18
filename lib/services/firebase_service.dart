import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await _setupFirestore();
    await _setupMessaging();
  }

  // Setup Firestore
  static Future<void> _setupFirestore() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Setup Firebase Messaging
  static Future<void> _setupMessaging() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
      });
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Background message: ${message.messageId}");
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore => _firestore;

  // Get Auth instance
  static FirebaseAuth get auth => _auth;

  // Get Storage instance
  static FirebaseStorage get storage => _storage;

  // Get Messaging instance
  static FirebaseMessaging get messaging => _messaging;

  // Collection references
  static CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> get jobs =>
      _firestore.collection('jobs');

  static CollectionReference<Map<String, dynamic>> get applications =>
      _firestore.collection('applications');

  static CollectionReference<Map<String, dynamic>> get resumes =>
      _firestore.collection('resumes');

  static CollectionReference<Map<String, dynamic>> get messages =>
      _firestore.collection('messages');

  static CollectionReference<Map<String, dynamic>> get conversations =>
      _firestore.collection('conversations');

  static CollectionReference<Map<String, dynamic>> get notifications =>
      _firestore.collection('notifications');

  static CollectionReference<Map<String, dynamic>> get companies =>
      _firestore.collection('companies');

  // Run transaction
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction,
  ) async {
    return await _firestore.runTransaction(transactionFunction);
  }

  // Run batch
  static Future<void> runBatch(List<Function(WriteBatch batch)> operations) async {
    final batch = _firestore.batch();
    for (var operation in operations) {
      operation(batch);
    }
    await batch.commit();
  }

  // Generate document ID
  static String generateId(String collection) {
    return _firestore.collection(collection).doc().id;
  }

  // Get server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Delete collection (use with caution)
  static Future<void> deleteCollection(String collectionPath) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection(collectionPath).get();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Enable offline persistence
  static Future<void> enablePersistence() async {
    await _firestore.enableNetwork();
  }

  // Disable offline persistence
  static Future<void> disablePersistence() async {
    await _firestore.disableNetwork();
  }

  // Clear persistence
  static Future<void> clearPersistence() async {
    await _firestore.clearPersistence();
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}