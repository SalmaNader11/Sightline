import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Import for isDarkThemeNotifier

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkTheme;
  late bool _notificationsEnabled;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _isDarkTheme = isDarkThemeNotifier.value;
    _notificationsEnabled = true; // Default state
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Dyslexia Helper Notifications',
      channelDescription: 'Notifications for Dyslexia Helper app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      'Dyslexia Helper',
      'This is a test notification!',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: isDark ? Colors.black : Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: isDark ? Colors.black : null,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                children: [
                  Icon(Icons.settings, size: 30, color: isDark ? Colors.purple : Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: isDark ? Colors.black : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDark ? BorderSide(color: Colors.purple.withOpacity(0.5), width: 1) : BorderSide.none,
                ),
                child: SwitchListTile(
                  title: Text(
                    'Dark Theme',
                    style: TextStyle(color: isDark ? Colors.white : null),
                  ),
                  subtitle: Text(
                    'Enable dark mode for the app',
                    style: TextStyle(color: isDark ? Colors.white70 : null),
                  ),
                  value: _isDarkTheme,
                  onChanged: (value) {
                    setState(() {
                      _isDarkTheme = value;
                      isDarkThemeNotifier.value = value; // Update global theme
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dark Theme: ${_isDarkTheme ? 'On' : 'Off'}')),
                    );
                  },
                  secondary: Icon(
                    Icons.brightness_6,
                    color: isDark ? Colors.purple : null,
                  ),
                  activeColor: isDark ? Colors.purple : Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                color: isDark ? Colors.black : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDark ? BorderSide(color: Colors.purple.withOpacity(0.5), width: 1) : BorderSide.none,
                ),
                child: SwitchListTile(
                  title: Text(
                    'Notifications',
                    style: TextStyle(color: isDark ? Colors.white : null),
                  ),
                  subtitle: Text(
                    'Receive app notifications',
                    style: TextStyle(color: isDark ? Colors.white70 : null),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                      if (_notificationsEnabled) {
                        _showNotification(); // Show a test notification when enabled
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notifications: ${_notificationsEnabled ? 'On' : 'Off'}')),
                    );
                  },
                  secondary: Icon(
                    Icons.notifications,
                    color: isDark ? Colors.purple : null,
                  ),
                  activeColor: isDark ? Colors.purple : Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: isDark ? Colors.black : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDark ? BorderSide(color: Colors.purple.withOpacity(0.5), width: 1) : BorderSide.none,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.info,
                    color: isDark ? Colors.purple : Colors.blue,
                  ),
                  title: Text(
                    'About Dyslexia Helper',
                    style: TextStyle(color: isDark ? Colors.white : null),
                  ),
                  subtitle: Text(
                    'Version 1.0.0\nA tool to assist with dyslexia support.',
                    style: TextStyle(color: isDark ? Colors.white70 : null),
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Dyslexia Helper',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 xAI',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}