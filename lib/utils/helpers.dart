import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  // Format time
  static String formatTime(DateTime time, {String format = 'h:mm a'}) {
    final formatter = DateFormat(format);
    return formatter.format(time);
  }

  // Format date time
  static String formatDateTime(DateTime dateTime, {String format = 'MMM dd, yyyy • h:mm a'}) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  // Get time ago
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Format salary
  static String formatSalary(double? min, double? max, {String currency = '\$'}) {
    if (min == null && max == null) {
      return 'Not specified';
    }
    
    if (min != null && max != null) {
      if (min == max) {
        return '$currency${min.round()}k';
      }
      return '$currency${min.round()}k - $currency${max.round()}k';
    }
    
    if (min != null) {
      return '$currency${min.round()}k+';
    }
    
    return 'Up to $currency${max!.round()}k';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get random color
  static Color getRandomColor(String seed) {
    final hash = seed.hashCode.abs();
    final hue = hash % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.8).toColor();
  }

  // Calculate match percentage between job and user skills
  static int calculateMatchPercentage(JobModel job, List<String> userSkills) {
    if (job.skills.isEmpty || userSkills.isEmpty) return 0;
    
    final matchingSkills = job.skills.where((skill) => 
      userSkills.any((userSkill) => 
        userSkill.toLowerCase().contains(skill.toLowerCase())
      )
    ).length;
    
    return ((matchingSkills / job.skills.length) * 100).round();
  }

  // Group applications by status
  static Map<ApplicationStatus, List<ApplicationModel>> groupApplicationsByStatus(
    List<ApplicationModel> applications,
  ) {
    final grouped = <ApplicationStatus, List<ApplicationModel>>{};
    
    for (var status in ApplicationStatus.values) {
      grouped[status] = [];
    }
    
    for (var app in applications) {
      grouped[app.status]?.add(app);
    }
    
    return grouped;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  // Validate URL
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(url);
  }

  // Get file extension from file name
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Check if file is an image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Check if file is a PDF
  static bool isPdfFile(String fileName) {
    final extension = getFileExtension(fileName);
    return extension == 'pdf';
  }

  // Get file icon based on extension
  static IconData getFileIcon(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'mp4':
      case 'mov':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file color based on extension
  static Color getFileColor(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Convert hex color to Color
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Get platform name
  static String getPlatform() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // Check if running on mobile
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // Check if running on web
  static bool get isWeb => identical(0, 0.0); // Simple web detection
}