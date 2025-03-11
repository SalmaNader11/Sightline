import 'package:flutter/material.dart';
import 'smart_scan/smart_scan_home_screen.dart';

// This file is kept for backward compatibility
// The implementation has been moved to the smart_scan directory
class SmartScanScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFileUploaded;

  const SmartScanScreen({super.key, required this.onFileUploaded});

  @override
  State<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends State<SmartScanScreen> {
  @override
  Widget build(BuildContext context) {
    // Redirect to the new implementation
    return SmartScanHomeScreen(onFileUploaded: widget.onFileUploaded);
  }
}
