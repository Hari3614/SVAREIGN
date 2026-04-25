import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/notification/notification_provider.dart';
import 'package:svareign/widgets/notification_banner.dart';

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                notificationProvider.showNotification(
                  title: 'Test Notification',
                  message:
                      'This is a test notification message to demonstrate the notification system.',
                  duration: Duration(seconds: 5),
                );
              },
              child: Text('Show Test Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificationProvider.showNotification(
                  title: 'Service Request Received',
                  message:
                      'John Smith has sent you a service request for plumbing repair.',
                  duration: Duration(seconds: 5),
                );
              },
              child: Text('Show Service Request Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificationProvider.clearAllNotifications();
              },
              child: Text('Clear All Notifications'),
            ),
            SizedBox(height: 20),
            Text(
              'Notifications (${notificationProvider.notifications.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notificationProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      notificationProvider.notifications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
