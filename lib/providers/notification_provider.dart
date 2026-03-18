import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../config/firebase_config.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<JobAlertModel> _jobAlerts = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<JobAlertModel> get jobAlerts => _jobAlerts;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load notifications for user
  Future<void> loadNotifications(String userId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading notifications: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Stream notifications
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return FirebaseConfig.notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
          
          _notifications = notifications;
          _updateUnreadCount();
          
          return notifications;
        });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseConfig.notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error marking notification as read: $e';
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final unread = await FirebaseConfig.notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local list
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error marking all as read: $e';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseConfig.notificationsCollection.doc(notificationId).delete();

      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting notification: $e';
      notifyListeners();
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      final snapshot = await FirebaseConfig.notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error clearing notifications: $e';
      notifyListeners();
    }
  }

  // Load job alerts - FIXED: JobAlertModel uses a different collection
  Future<void> loadJobAlerts(String userId) async {
    try {
      _setLoading(true);

      // Job alerts should be stored in a separate collection or as a different type
      // For now, we'll assume they're in a 'jobAlerts' subcollection or a separate collection
      final snapshot = await FirebaseConfig.usersCollection
          .doc(userId)
          .collection('jobAlerts')
          .get();

      _jobAlerts = snapshot.docs
          .map((doc) => JobAlertModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading job alerts: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Alternative: If job alerts are stored in notifications collection with type field
  // This method assumes you want to filter notifications by type
  Future<void> loadJobAlertsFromNotifications(String userId) async {
    try {
      _setLoading(true);

      final snapshot = await FirebaseConfig.notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'job_alert')
          .orderBy('createdAt', descending: true)
          .get();

      // Convert NotificationModel to JobAlertModel if needed, or handle separately
      // This depends on your data structure
      final notificationAlerts = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      // If you need to convert to JobAlertModel, you'd do that here
      // For now, we'll just store them as notifications
      _notifications.addAll(notificationAlerts);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading job alerts from notifications: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create job alert - FIXED: Use the correct collection
  Future<bool> createJobAlert(JobAlertModel alert) async {
    try {
      _setLoading(true);

      // Save to user's jobAlerts subcollection
      await FirebaseConfig.usersCollection
          .doc(alert.userId)
          .collection('jobAlerts')
          .doc(alert.id)
          .set(alert.toFirestore());

      _jobAlerts.add(alert);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Error creating job alert: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update job alert - FIXED: Use correct collection and update method
  Future<void> updateJobAlert(JobAlertModel alert) async {
    try {
      await FirebaseConfig.usersCollection
          .doc(alert.userId)
          .collection('jobAlerts')
          .doc(alert.id)
          .update(alert.toFirestore());

      // Update local list
      final index = _jobAlerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        // Since JobAlertModel doesn't have copyWith, we need to replace it
        _jobAlerts[index] = alert;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating job alert: $e';
      notifyListeners();
    }
  }

  // Delete job alert - FIXED: Use correct collection
  Future<void> deleteJobAlert(String userId, String alertId) async {
    try {
      await FirebaseConfig.usersCollection
          .doc(userId)
          .collection('jobAlerts')
          .doc(alertId)
          .delete();

      _jobAlerts.removeWhere((a) => a.id == alertId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting job alert: $e';
      notifyListeners();
    }
  }

  // Toggle job alert active status - FIXED: Proper update without copyWith
  Future<void> toggleJobAlert(String userId, String alertId, bool isActive) async {
    try {
      await FirebaseConfig.usersCollection
          .doc(userId)
          .collection('jobAlerts')
          .doc(alertId)
          .update({'isActive': isActive});

      // Update local list
      final index = _jobAlerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        // Create updated alert manually since copyWith doesn't exist
        final oldAlert = _jobAlerts[index];
        final updatedAlert = JobAlertModel(
          id: oldAlert.id,
          userId: oldAlert.userId,
          title: oldAlert.title,
          keywords: oldAlert.keywords,
          location: oldAlert.location,
          jobType: oldAlert.jobType,
          salaryMin: oldAlert.salaryMin,
          salaryMax: oldAlert.salaryMax,
          categories: oldAlert.categories,
          isActive: isActive,
          frequency: oldAlert.frequency,
          createdAt: oldAlert.createdAt,
          lastTriggered: oldAlert.lastTriggered,
          notificationCount: oldAlert.notificationCount,
        );
        
        _jobAlerts[index] = updatedAlert;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error toggling job alert: $e';
      notifyListeners();
    }
  }

  // Add a new notification (for system use)
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await FirebaseConfig.notificationsCollection
          .doc(notification.id)
          .set(notification.toFirestore());

      _notifications.insert(0, notification);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error adding notification: $e';
      notifyListeners();
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}