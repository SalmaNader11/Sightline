import 'package:flutter/material.dart';
import 'reset_password_screen.dart'; // Import new screen

class VerificationCodeScreen extends StatefulWidget {
  final String emailOrUsername;

  VerificationCodeScreen({required this.emailOrUsername});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      // Simulate code verification (replace with backend check in real app)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code verified: ${_codeController.text}'),
        ),
      );

      // Navigate to ResetPasswordScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            emailOrUsername: widget.emailOrUsername,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'A code has been sent to ${widget.emailOrUsername}. Enter it below.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Verification Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) { // Assuming a 6-digit code
                    return 'Code must be 6 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCode,
                child: Text('Verify Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}