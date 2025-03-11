import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'text_to_speech_screen.dart';

class SmartScanResultScreen extends StatefulWidget {
  final String extractedText;
  final bool isHandwritingMode; // Add parameter to know if handwriting mode was used

  SmartScanResultScreen({
    required this.extractedText, 
    this.isHandwritingMode = false, // Default to false for backward compatibility
  });

  @override
  _SmartScanResultScreenState createState() => _SmartScanResultScreenState();
}

class _SmartScanResultScreenState extends State<SmartScanResultScreen> {
  late TextEditingController _textController;
  bool _isSaving = false;
  bool _isFormatted = true; // Track if text is formatted

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.extractedText);
    
    // Add debug print to check if text is being received
    print('SmartScanResultScreen received text: "${widget.extractedText}"');
    print('Text length: ${widget.extractedText.length}');
    
    // Show success message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.extractedText.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHandwritingMode 
                ? 'Handwriting recognized successfully!' 
                : 'Text extracted successfully!'
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show message if no text was extracted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No text was extracted. Try adjusting the image or scan settings.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _shareText() async {
    await Share.share(_textController.text, subject: 'Scanned Text');
  }

  void _saveToFile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'scanned_text_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(_textController.text);
      
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text saved to $fileName')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving text: $e')),
      );
    }
  }

  void _speakText() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TextToSpeechScreen(extractedText: _textController.text)),
    );
  }
  
  // Toggle between formatted and raw text
  void _toggleFormatting() {
    setState(() {
      if (_isFormatted) {
        // Switch to raw text - preserve all whitespace
        _textController.text = widget.extractedText;
      } else {
        // Switch to formatted text
        _textController.text = _formatText(widget.extractedText);
      }
      _isFormatted = !_isFormatted;
    });
  }
  
  // Format text for better readability
  String _formatText(String text) {
    if (text.isEmpty) return text;
    
    // Replace multiple spaces with a single space
    String formatted = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    // Replace multiple newlines with a single newline
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Add paragraph spacing
    formatted = formatted.replaceAll('\n', '\n\n');
    
    // Remove any double paragraph spacing we might have created
    formatted = formatted.replaceAll('\n\n\n\n', '\n\n');
    
    return formatted.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHandwritingMode ? 'Handwriting Recognition' : 'Smart Scan Result'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: 'Copy to Clipboard',
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save to File',
            onPressed: _isSaving ? null : _saveToFile,
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'Share Text',
            onPressed: _shareText,
          ),
          IconButton(
            icon: Icon(Icons.volume_up),
            tooltip: 'Speak',
            onPressed: _speakText,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top indicator bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: widget.isHandwritingMode 
                ? Colors.amber.withOpacity(0.1) 
                : Colors.blue.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isHandwritingMode ? Icons.edit : Icons.text_fields,
                  color: widget.isHandwritingMode ? Colors.amber[800] : Colors.blue[800],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  widget.isHandwritingMode ? 'Handwritten Text' : 'Extracted Text',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: widget.isHandwritingMode ? Colors.amber[800] : Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          
          // Main content - Large text display area
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: widget.isHandwritingMode 
                      ? Colors.amber.withOpacity(0.5) 
                      : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: widget.extractedText.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.text_snippet_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No text was extracted',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try scanning again with different settings',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Extracted text will appear here...',
                      ),
                      style: TextStyle(
                        fontSize: 22, // Larger text size
                        height: 1.5,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                        fontFamily: widget.isHandwritingMode ? 'Roboto' : null,
                      ),
                    ),
            ),
          ),
          
          // Bottom action buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: Icon(Icons.copy),
                  label: Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveToFile,
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shareText,
                  icon: Icon(Icons.share),
                  label: Text('Share'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _speakText,
                  icon: Icon(Icons.volume_up),
                  label: Text('Speak'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}