import 'package:flutter/material.dart';
import 'data/data_model/user_data.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/user_info.dart';

void main() {
  runApp(DyslexiaApp());
}

class DyslexiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'slight line',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegistrationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final UserData? userData; // Accept user data

  MainScreen({this.userData});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<String> _recentFiles = [];
  List<String> _favoriteFiles = [];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(recentFiles: _recentFiles),
      UploadScreen(onFileUploaded: _onFileUploaded),
      FavoritesScreen(favoriteFiles: _favoriteFiles, onAddFavorite: _addFavorite),
      UserInfoScreen(userData: widget.userData), // Pass user data to UserInfoScreen
    ];
  }

  void _onFileUploaded(String fileText) {
    setState(() {
      _recentFiles.insert(0, fileText);
      if (_recentFiles.length > 5) _recentFiles.removeLast();
      _selectedIndex = 0;
    });
  }

  void _addFavorite(String fileText) {
    setState(() {
      if (!_favoriteFiles.contains(fileText)) {
        _favoriteFiles.add(fileText);
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
      appBar: AppBar(
        title: Text('slight line'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User Info'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white70,
        onTap: _onItemTapped,
      ),
    );
  }
}