import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final PermissionStatus status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  // Request gallery/photos permission (handles Android/iOS differences)
  static Future<bool> requestPhotosPermission() async {
    try {
      // Check if already granted
      final bool photosGranted = await Permission.photos.isGranted;
      if (photosGranted) {
        return true;
      }
      
      // For Android, also check storage permission as fallback
      if (Platform.isAndroid) {
        final bool storageGranted = await Permission.storage.isGranted;
        if (storageGranted) {
          return true;
        }
      }
      
      // Request photos permission
      final PermissionStatus status = await Permission.photos.request();
      
      // If photos permission is not available on older Android, try storage
      if (Platform.isAndroid && !status.isGranted) {
        final PermissionStatus storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      return false;
    }
  }

  // Request storage permission (for Android < 13)
  static Future<bool> requestStoragePermission() async {
    try {
      final PermissionStatus status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final PermissionStatus status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  // Request contacts permission
  static Future<bool> requestContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting contacts permission: $e');
      return false;
    }
  }

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    try {
      return await permissions.request();
    } catch (e) {
      debugPrint('Error requesting multiple permissions: $e');
      return <Permission, PermissionStatus>{};
    }
  }

  // Check if permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    try {
      final PermissionStatus status = await permission.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking permission status: $e');
      return false;
    }
  }

  // Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final PermissionStatus status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Error checking permission permanently denied: $e');
      return false;
    }
  }

  // Open app settings
  static Future<void> openAppSettingsPage() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  // Get permission status
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      debugPrint('Error getting permission status: $e');
      return PermissionStatus.denied;
    }
  }

  // Check if we should show permission rationale (Android only)
  static Future<bool> shouldShowRequestRationale(Permission permission) async {
    try {
      if (!Platform.isAndroid) return false;
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      debugPrint('Error checking should show rationale: $e');
      return false;
    }
  }

  // Required permissions for features
  static Future<bool> hasRequiredPermissionsForFeature(String feature) async {
    try {
      switch (feature) {
        case 'camera':
          return await isPermissionGranted(Permission.camera);
        case 'gallery':
          // For gallery, check both photos and storage on Android
          if (Platform.isAndroid) {
            final bool photosGranted = await isPermissionGranted(Permission.photos);
            final bool storageGranted = await isPermissionGranted(Permission.storage);
            return photosGranted || storageGranted;
          }
          return await isPermissionGranted(Permission.photos);
        case 'notifications':
          return await isPermissionGranted(Permission.notification);
        case 'microphone':
          return await isPermissionGranted(Permission.microphone);
        case 'location':
          return await isPermissionGranted(Permission.location);
        case 'contacts':
          return await isPermissionGranted(Permission.contacts);
        case 'storage':
          return await isPermissionGranted(Permission.storage);
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Error checking required permissions: $e');
      return false;
    }
  }

  // Request all required permissions for a feature
  static Future<bool> requestRequiredPermissionsForFeature(String feature) async {
    try {
      switch (feature) {
        case 'camera':
          return await requestCameraPermission();
        case 'gallery':
          return await requestPhotosPermission();
        case 'notifications':
          return await requestNotificationPermission();
        case 'microphone':
          return await requestMicrophonePermission();
        case 'location':
          return await requestLocationPermission();
        case 'contacts':
          return await requestContactsPermission();
        case 'storage':
          return await requestStoragePermission();
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Error requesting required permissions: $e');
      return false;
    }
  }

  // Show permission denied dialog
  static Future<void> showPermissionDeniedDialog({
    required BuildContext context,
    required String permissionName,
    required String feature,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
            '$permissionName permission is required to use $feature. '
            'Please enable it in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettingsPage();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Check and request permission with rationale
  static Future<bool> checkAndRequestPermission({
    required Permission permission,
    required String permissionName,
    required String feature,
    BuildContext? context,
  }) async {
    try {
      // Check if already granted
      if (await isPermissionGranted(permission)) {
        return true;
      }

      // Check if permanently denied
      if (await isPermissionPermanentlyDenied(permission)) {
        if (context != null) {
          await showPermissionDeniedDialog(
            context: context,
            permissionName: permissionName,
            feature: feature,
          );
        }
        return false;
      }

      // Request permission
      final PermissionStatus status = await permission.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied && context != null) {
        await showPermissionDeniedDialog(
          context: context,
          permissionName: permissionName,
          feature: feature,
        );
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in checkAndRequestPermission: $e');
      return false;
    }
  }

  // Check multiple permissions
  static Future<Map<Permission, bool>> checkMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final Map<Permission, bool> result = <Permission, bool>{};
    
    for (final Permission permission in permissions) {
      result[permission] = await isPermissionGranted(permission);
    }
    
    return result;
  }

  // Request permissions with explanation
  static Future<bool> requestPermissionWithExplanation({
    required Permission permission,
    required String permissionName,
    required String explanation,
    required BuildContext context,
  }) async {
    // Show explanation dialog first
    final bool shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission'),
          content: Text(explanation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    ) ?? false;

    if (!shouldProceed) {
      return false;
    }

    return await checkAndRequestPermission(
      permission: permission,
      permissionName: permissionName,
      feature: 'this feature',
      context: context,
    );
  }
}