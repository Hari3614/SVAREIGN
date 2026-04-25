import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  bool _hasNewNotifications = false;
  bool get hasNewNotifications => _hasNewNotifications;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _hasNewNotifications = true;
    notifyListeners();
  }

  void removeNotification(NotificationItem notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _hasNewNotifications = false;
    notifyListeners();
  }

  void markAsRead() {
    _hasNewNotifications = false;
    notifyListeners();
  }

  void showNotification({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      duration: duration,
    );

    addNotification(notification);
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final Duration duration;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.duration,
    this.isRead = false,
  });
}
