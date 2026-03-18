// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with your actual Firebase web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your Web API Key
    appId: '1:406743820372:web:609254f42027bec3cc65c1', // Your Web App ID
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    authDomain: 'jobconnect-12.firebaseapp.com', // Your Auth Domain
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
    measurementId: 'G-1FPEYYKJRR', // Your Measurement ID (optional)
  );

  // TODO: Replace with your actual Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your Android API Key
    appId: '1:406743820372:android:86064f1698ebab23cc65c1', // Your Android App ID
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
  );

  // TODO: Replace with your actual Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your iOS API Key
    appId: '1:406743820372:ios:4abed7ffaa1e2238cc65c1', // Your iOS App ID
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
    iosClientId: '123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com', // Your iOS Client ID
    iosBundleId: 'com.example.jobconnect', // Your iOS Bundle ID
  );

  // TODO: Replace with your actual Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your macOS API Key
    appId: '1:406743820372:ios:4abed7ffaa1e2238cc65c1', // Your macOS App ID (usually same as iOS)
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
    iosClientId: '123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com', // Your macOS Client ID
    iosBundleId: 'com.example.jobconnect', // Your macOS Bundle ID
  );

  // TODO: Replace with your actual Firebase Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your Android API Key
    appId: '1:406743820372:android:86064f1698ebab23cc65c1', // Your Android App ID
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
  );

  // TODO: Replace with your actual Firebase Linux configuration
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI', // Your Android API Key
    appId: '1:406743820372:android:86064f1698ebab23cc65c1', // Your Android App ID
    messagingSenderId: '406743820372', // Your Sender ID
    projectId: 'jobconnect-12', // Your Project ID
    storageBucket: 'jobconnect-12.firebasestorage.app', // Your Storage Bucket
  );
}