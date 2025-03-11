import 'package:flutter/material.dart';
import '../data/data_model/user_data.dart';
import 'registration_screen.dart'; // Import for sign-out navigation

class UserInfoScreen extends StatelessWidget {
  final UserData? userData;

  UserInfoScreen({this.userData});

  void _signOut(BuildContext context) {
    // Navigate back to RegistrationScreen and remove MainScreen from the stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 30, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'User Info',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // User data card
          if (userData != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //_buildInfoRow(Icons.person_outline, 'Username', userData!.username),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.email, 'Email', userData!.email),
                    SizedBox(height: 12),
                    //_buildInfoRow(Icons.phone, 'Phone', userData!.phone),
                  ],
                ),
              ),
            )
          else
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No user data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          SizedBox(height: 30),
          // Sign Out button
          ElevatedButton.icon(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout),
            label: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
              foregroundColor: Colors.white, // Text/icon color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each info row with icon and text
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}