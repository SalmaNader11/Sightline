import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'models/user_data.dart';
import 'screens/home_screen.dart';
import 'screens/user_info.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart'; 

final ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(DyslexiaApp());
}

class DyslexiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkThemeNotifier,
      builder: (context, isDarkTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isDarkTheme
              ? ThemeData.dark().copyWith(
                  primaryColor: Colors.purple,
                  scaffoldBackgroundColor: Colors.black,
                  colorScheme: ColorScheme.dark(
                    primary: Colors.purple,
                    secondary: Colors.purpleAccent,
                    surface: Colors.black,
                    background: Colors.black,
                    onPrimary: Colors.white,
                    onSecondary: Colors.white,
                    onSurface: Colors.white,
                    onBackground: Colors.white,
                  ),
                  appBarTheme: AppBarTheme(backgroundColor: Colors.black),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Colors.black,
                    selectedItemColor: Colors.purple,
                    unselectedItemColor: Colors.white70,
                  ),
                  cardColor: Colors.black,
                  dialogBackgroundColor: Colors.black,
                  dividerColor: Colors.purple[700],
                  textTheme: TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white),
                    titleLarge: TextStyle(color: Colors.white),
                    titleMedium: TextStyle(color: Colors.white),
                  ),
                  iconTheme: IconThemeData(color: Colors.purple),
                )
              : ThemeData(
                  primarySwatch: Colors.blue,
                  scaffoldBackgroundColor: Colors.white,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Color(0xFF1E90FF),
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.black54,
                  ),
                ),
          home: AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return MainScreen(); 
        } else {
          return SignInScreen(); 
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final UserData? userData;
  MainScreen({this.userData});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _recentFiles = [
    {'name': 'file1.pdf', 'timestamp': DateTime.now().toString()},
    {'name': 'file2.pdf', 'timestamp': DateTime.now().subtract(Duration(minutes: 5)).toString()},
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        recentFiles: _recentFiles,
        onFilesDeleted: _onFilesDeleted,
        onFileUploaded: _onFileUploaded,
      ),
      UserInfoScreen(userData: widget.userData),
      SettingsScreen(),
    ];
  }

  void _onFileUploaded(Map<String, dynamic> file) {
    setState(() {
      _recentFiles.insert(0, file);
      if (_recentFiles.length > 5) _recentFiles.removeLast();
      _selectedIndex = 0;
    });
  }

  void _onFilesDeleted(List<int> indicesToDelete) {
    setState(() {
      indicesToDelete.sort((a, b) => b.compareTo(a));
      for (int index in indicesToDelete) {
        _recentFiles.removeAt(index);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sightline')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User Info'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
