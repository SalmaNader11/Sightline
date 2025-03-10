import 'package:flutter/material.dart';
import 'verification_code_screen.dart'; // Import new screen

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();

  void _submitForgotPassword() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending a code (replace with backend call in real app)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification code sent to ${_emailOrUsernameController.text}',
          ),
        ),
      );

      // Navigate to VerificationCodeScreen with the entered email/username
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodeScreen(
            emailOrUsername: _emailOrUsernameController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Enter your email or username to receive a verification code',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForgotPassword,
                child: Text('Send Code'),
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
    super.dispose();
  }
}