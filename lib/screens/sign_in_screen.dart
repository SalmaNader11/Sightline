import 'package:flutter/material.dart';
import '../data/data_model/user_data.dart';
import '../main.dart';
import 'registration_screen.dart';
import 'forget_password_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>(); // Ensure this is correctly defined
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitSignIn() {
    print('Submitting sign-in...'); // Debug print
    if (_formKey.currentState!.validate()) {
      print('Sign-in form is valid'); // Debug print
      UserData userData = UserData(
        // username: _emailOrUsernameController.text,
        email: '',
        // phone: '',
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Signed in with: ${_emailOrUsernameController.text}')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userData: userData)),
      );
    } else {
      print('Sign-in form validation failed'); // Debug print
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login here'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Ensure the form key is attached
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFADD8E6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailOrUsernameController,
                        decoration: InputDecoration(
                            labelText: 'Email', border: InputBorder.none),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email or username';
                          }
                          return null;
                        },
                      ),
                      Divider(color: Color(0xFFADD8E6)),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password', border: InputBorder.none),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 16, color: Color(0xFF1E90FF)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitSignIn, // Ensure this is correctly wired
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E90FF),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Sign In',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    'Create new account',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1E90FF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}