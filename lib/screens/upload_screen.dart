import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class UploadScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFileUploaded; // Updated type

  UploadScreen({required this.onFileUploaded});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Future<void> _pickAndExtractPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name; // Get the file name
      PdfDocument document = PdfDocument(inputBytes: await File(filePath).readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      // Pass a Map with name, timestamp, and optionally the extracted text
      widget.onFileUploaded({
        'name': fileName,
        'timestamp': DateTime.now().toString(),
        'text': text, // Optional: Include extracted text if needed later
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _pickAndExtractPDF,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1E90FF), // Match app theme
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Pick a File',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}