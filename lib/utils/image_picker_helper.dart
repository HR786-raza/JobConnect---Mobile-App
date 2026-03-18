import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Check if running on Android
  static Future<bool> isAndroid() async {
    if (Platform.isAndroid) {
      await _deviceInfo.androidInfo;
      return true;
    }
    return false;
  }

  // Get Android version
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  // Request gallery permission (handles different Android versions)
  static Future<bool> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      // iOS - request photos permission
      final status = await Permission.photos.request();
      return status.isGranted;
    } else if (Platform.isAndroid) {
      final sdkInt = await _getAndroidVersion();
      
      if (sdkInt >= 33) { // Android 13+
        // For Android 13+, use photos permission
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // For older Android, use storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return false;
  }

  // Request camera permission
  static Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      // Request permission
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Gallery permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      // Request permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick multiple images
  static Future<List<File>?> pickMultiImages({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
    int maxImages = 10,
  }) async {
    try {
      // Request permission
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Gallery permission denied');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (images.length > maxImages) {
        throw Exception('Maximum $maxImages images allowed');
      }

      if (images.isNotEmpty) {
        return images.map((image) => File(image.path)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return null;
    }
  }

  // Check if we have gallery permission
  static Future<bool> hasGalleryPermission() async {
    if (Platform.isIOS) {
      return await Permission.photos.status.isGranted;
    } else if (Platform.isAndroid) {
      final sdkInt = await _getAndroidVersion();
      if (sdkInt >= 33) {
        return await Permission.photos.status.isGranted;
      } else {
        return await Permission.storage.status.isGranted;
      }
    }
    return false;
  }

  // Check if we have camera permission
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  // Show image source selection dialog
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show permission denied dialog
  static Future<void> showPermissionDeniedDialog(
    BuildContext context, {
    required String permission,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permission permission is required to use this feature. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}