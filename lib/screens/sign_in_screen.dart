import 'package:flutter/material.dart';
import '../data/data_model/user_data.dart';
import '../main.dart';
import 'registration_screen.dart';
import 'forget_password_screen.dart'; // Import ForgotPasswordScreen

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitSignIn() {
    if (_formKey.currentState!.validate()) {
      // Create a dummy UserData with emailOrUsername as username for demo
      UserData userData = UserData(
        username: _emailOrUsernameController.text, // Treat as username for simplicity
        email: '', // Empty since not fully populated
        phone: '',
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in with: ${_emailOrUsernameController.text}')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userData: userData)),
      );
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
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailOrUsernameController,
                decoration: InputDecoration(labelText: 'Email or Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitSignIn,
                child: Text('Sign In'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _navigateToRegister,
                child: Text(
                  'Don’t have an account? Register',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}