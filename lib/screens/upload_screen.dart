import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class UploadScreen extends StatefulWidget {
  final Function(String) onFileUploaded;

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
      PdfDocument document = PdfDocument(inputBytes: await File(filePath).readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      widget.onFileUploaded(text); // Pass extracted text
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _pickAndExtractPDF,
        child: Text('Pick a File'),
      ),
    );
  }
}