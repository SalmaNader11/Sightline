import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'smart_scan_result_screen.dart';

class SmartScanScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFileUploaded;

  const SmartScanScreen({super.key, required this.onFileUploaded});

  @override
  State<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends State<SmartScanScreen> {
  bool _isProcessing = false;
  String _statusMessage = '';
  bool _isHandwritingMode = false;
  String _extractedText = '';
  final TextEditingController _textController = TextEditingController();
  late final TextRecognizer _textRecognizer;
  double _handwritingConfidence = 0.0;
  
  // Advanced settings for text recognition
  int _recognitionQuality = 2; // 1=fast, 2=balanced, 3=accurate
  bool _enhancedCorrection = true;
  bool _showRawText = false;
  String _rawExtractedText = '';

  @override
  void initState() {
    super.initState();
    // Initialize text recognizer with script detection
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      bool permissionsGranted = await _checkAndRequestPermissions();
      if (!permissionsGranted) return;
      
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      
      if (pickedFile != null) {
        setState(() {
          _isProcessing = true;
          _statusMessage = 'Processing image...';
        });
        
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      bool permissionsGranted = await _checkAndRequestPermissions();
      if (!permissionsGranted) return;
      
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (pickedFile != null) {
        setState(() {
          _isProcessing = true;
          _statusMessage = 'Processing image...';
        });
        
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // Apply image preprocessing for better recognition
      setState(() {
        _statusMessage = 'Enhancing image...';
      });
      
      File enhancedImage = await _enhanceImageForOCR(imageFile);
      
      final inputImage = InputImage.fromFile(enhancedImage);
      
      setState(() {
        _statusMessage = 'Analyzing image...';
      });
      
      // Process the image with appropriate settings based on handwriting mode
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String extractedText = recognizedText.text;
      
      // Check if text was actually extracted
      if (extractedText.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text detected in the image')),
        );
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
        
        // Still navigate to result screen even if no text was found
        _processRecognizedText('');
        return;
      }
      
      _rawExtractedText = extractedText; // Store raw text for comparison
      
      setState(() {
        _statusMessage = 'Processing text...';
      });
      
      // Apply different processing based on mode and quality settings
      if (_isHandwritingMode) {
        // For handwriting, process each text block separately for better results
        String combinedText = '';
        double totalConfidence = 0.0;
        int blockCount = 0;
        
        for (TextBlock block in recognizedText.blocks) {
          String blockText = block.text;
          // Process each block of handwritten text
          blockText = _processHandwrittenText(blockText);
          combinedText += blockText + ' ';
          
          // Calculate average confidence for handwriting detection
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              // Use null-safe access with default value
              totalConfidence += element.confidence ?? 0.5;
              blockCount++;
            }
          }
        }
        
        // Set average confidence with proper error handling
        _handwritingConfidence = blockCount > 0 ? (totalConfidence / blockCount).clamp(0.0, 1.0) : 0.5;
        
        extractedText = combinedText.trim();
        
        // Apply enhanced correction if enabled
        if (_enhancedCorrection) {
          extractedText = _applyEnhancedCorrection(extractedText);
        }
        
        // Apply advanced handwriting-specific corrections
        extractedText = _applyAdvancedHandwritingCorrections(extractedText);
      } else {
        extractedText = _processExtractedText(extractedText);
        
        // For printed text, calculate confidence from elements
        double totalConfidence = 0.0;
        int elementCount = 0;
        
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              // Use null-safe access with default value
              totalConfidence += element.confidence ?? 0.8;
              elementCount++;
            }
          }
        }
        
        _handwritingConfidence = elementCount > 0 ? (totalConfidence / elementCount).clamp(0.0, 1.0) : 0.9;
        
        // Apply enhanced correction if enabled
        if (_enhancedCorrection) {
          extractedText = _applyEnhancedCorrection(extractedText);
        }
      }
      
      _processRecognizedText(extractedText);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      
      // Still navigate to result screen even if there was an error
      _processRecognizedText('');
    }
  }

  void _processRecognizedText(String text) {
    setState(() {
      _extractedText = text;
      _textController.text = _formatTextForDisplay(text);
      _isProcessing = false;
      _statusMessage = '';
    });
    
    // Add file upload callback to maintain compatibility with the rest of the app
    String fileName = 'scanned_${DateTime.now().millisecondsSinceEpoch}.txt';
    widget.onFileUploaded({
      'name': fileName,
      'timestamp': DateTime.now().toString(),
      'type': 'smart_scan',
      'content': text,
    });
    
    // Always navigate to result screen after processing
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmartScanResultScreen(
            extractedText: _extractedText,
            isHandwritingMode: _isHandwritingMode,
          ),
        ),
      );
    }
  }

  String _processExtractedText(String text) {
    if (text.isEmpty) return text;
    
    // Replace multiple spaces with a single space
    String processed = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    // Fix common OCR issues - but don't blindly replace all instances
    // Only replace standalone characters or at word boundaries
    processed = processed.replaceAll(RegExp(r'\b1\b'), 'I'); // Only replace standalone '1' with 'I'
    processed = processed.replaceAll(RegExp(r'\b0\b'), 'O'); // Only replace standalone '0' with 'O'
    processed = processed.replaceAll(RegExp(r'\bl\b'), 'I'); // Only replace standalone 'l' with 'I'
    
    // Ensure proper spacing after punctuation
    processed = processed.replaceAll(RegExp(r'([.,!?:;])([^\s])'), r'$1 $2');
    
    return processed;
  }

  String _processHandwrittenText(String text) {
    if (text.isEmpty) return text;
    
    // Replace common handwriting OCR misrecognitions
    // Use word boundary markers to avoid incorrect replacements
    String processed = text;
    
    // Create a map of common misrecognized patterns and their corrections
    Map<String, String> patterns = {
      'cl': 'd',
      'rn': 'm',
      'vv': 'w',
      'lT': 'lt',
      'rnm': 'mm',
      'ii': 'u',
      'ri': 'n'
    };
    
    // Apply pattern corrections more carefully
    patterns.forEach((pattern, replacement) {
      // Only replace within words, not across word boundaries
      processed = processed.replaceAll(RegExp('(?<=\\w)$pattern(?=\\w)'), replacement);
    });
    
    // Fix common number/letter confusions - only at word boundaries
    processed = processed.replaceAll(RegExp(r'\bl1\b'), 'h');
    processed = processed.replaceAll(RegExp(r'\b0\b'), 'o');
    processed = processed.replaceAll(RegExp(r'\b1\b'), 'l');
    
    // Remove stray punctuation from handwriting artifacts
    processed = processed.replaceAll(RegExp(r'([^\w\s])\1+'), r'$1');
    
    // Improve spacing after punctuation
    processed = processed.replaceAll(RegExp(r'([.,!?:;])([^\s])'), r'$1 $2');
    
    // Fix spacing issues
    processed = processed.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    // Correct common word patterns
    processed = _correctCommonWords(processed);
    
    return processed;
  }

  String _correctCommonWords(String text) {
    // Create a map of common misrecognized words and their corrections
    Map<String, String> corrections = {
      'tlie': 'the',
      'tliat': 'that',
      'witli': 'with',
      'tliis': 'this',
      'tliese': 'these',
      'tliey': 'they',
      'tliem': 'them',
      'tliere': 'there',
      'tlieir': 'their',
      'tliough': 'though',
      'tlirough': 'through',
    };
    
    // Apply corrections
    String corrected = text;
    corrections.forEach((wrong, right) {
      corrected = corrected.replaceAll(RegExp('\\b$wrong\\b', caseSensitive: false), right);
    });
    
    return corrected;
  }

  String _applyEnhancedCorrection(String text) {
    if (text.isEmpty) return text;
    
    // Split text into words
    List<String> words = text.split(RegExp(r'\s+'));
    List<String> correctedWords = [];
    
    for (String word in words) {
      // Skip very short words or words with special characters
      if (word.length <= 2 || RegExp(r'[^\w\s]').hasMatch(word)) {
        correctedWords.add(word);
        continue;
      }
      
      // Apply common corrections based on word patterns
      String corrected = word;
      
      // Fix common OCR errors in word patterns
      if (word.contains('rn')) corrected = word.replaceAll('rn', 'm');
      if (word.contains('li')) corrected = word.replaceAll('li', 'h');
      if (word.contains('cl')) corrected = word.replaceAll('cl', 'd');
      if (word.contains('vv')) corrected = word.replaceAll('vv', 'w');
      
      // Fix common letter substitutions
      corrected = corrected
          .replaceAll('0', 'o')
          .replaceAll('1', 'l')
          .replaceAll('5', 's');
      
      // Apply dictionary-based corrections for common English words
      corrected = _correctCommonWords(corrected);
      
      correctedWords.add(corrected);
    }
    
    return correctedWords.join(' ');
  }

  String _formatTextForDisplay(String text) {
    if (text.isEmpty) return text;
    
    // Replace multiple spaces with a single space
    String formatted = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    // Replace multiple newlines with a single newline (but preserve paragraph breaks)
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Ensure proper paragraph spacing - but don't join lines that should be separate
    // Only add space if both characters are alphanumeric
    formatted = formatted.replaceAll(RegExp(r'([a-zA-Z0-9,;:])(\n)([a-zA-Z0-9])'), r'$1 $3');
    
    // Ensure proper spacing after punctuation
    formatted = formatted.replaceAll(RegExp(r'([.,!?:;])([^\s])'), r'$1 $2');
    
    return formatted;
  }

  Future<bool> _checkAndRequestPermissions() async {
    // For Android 13+ (API level 33+), we need to request granular permissions
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    
    if (androidInfo.version.sdkInt >= 33) {
      // For Android 13+, request camera and photos permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();
      
      // Check camera permission
      if (statuses[Permission.camera] != PermissionStatus.granted) {
        if (!mounted) return false;
        _showPermissionDeniedDialog('Camera');
        return false;
      }
      
      // Check photos permission - handle potential null with ?? operator
      if (statuses[Permission.photos] != PermissionStatus.granted) {
        if (!mounted) return false;
        _showPermissionDeniedDialog('Photos');
        return false;
      }
      
      return true;
    } else {
      // For older Android versions, request storage permission
      PermissionStatus storageStatus = await Permission.storage.request();
      
      if (storageStatus != PermissionStatus.granted) {
        if (!mounted) return false;
        _showPermissionDeniedDialog('Storage');
        return false;
      }
      
      // Also request camera permission
      PermissionStatus cameraStatus = await Permission.camera.request();
      
      if (cameraStatus != PermissionStatus.granted) {
        if (!mounted) return false;
        _showPermissionDeniedDialog('Camera');
        return false;
      }
      
      return true;
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text('Please grant $permissionType permission to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Recognition Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recognition Quality',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _recognitionQuality.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: _getQualityLabel(),
                  onChanged: (value) {
                    setState(() {
                      _recognitionQuality = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Enhanced Text Correction'),
                  subtitle: const Text('Apply advanced corrections to improve accuracy'),
                  value: _enhancedCorrection,
                  onChanged: (value) {
                    setState(() {
                      _enhancedCorrection = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (_extractedText.isNotEmpty) ...[
                  SwitchListTile(
                    title: const Text('Show Raw Text'),
                    subtitle: const Text('Display unprocessed recognition results'),
                    value: _showRawText,
                    onChanged: (value) {
                      setState(() {
                        _showRawText = value;
                      });
                      // Update the text controller with raw or processed text
                      this.setState(() {
                        if (_showRawText) {
                          _textController.text = _rawExtractedText;
                        } else {
                          _textController.text = _formatTextForDisplay(_extractedText);
                        }
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getQualityLabel() {
    switch (_recognitionQuality) {
      case 1:
        return 'Fast';
      case 2:
        return 'Balanced';
      case 3:
        return 'Accurate';
      default:
        return 'Balanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Add settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Recognition Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handwriting mode toggle with enhanced UI
              Container(
                decoration: BoxDecoration(
                  color: _isHandwritingMode ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isHandwritingMode ? Colors.blue : Colors.grey,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Handwriting Recognition Mode',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: _isHandwritingMode ? Colors.blue : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _isHandwritingMode 
                            ? 'Optimized for handwritten notes and cursive text'
                            : 'Enable for better handwriting recognition',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isHandwritingMode,
                      onChanged: (value) {
                        setState(() {
                          _isHandwritingMode = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    if (_isHandwritingMode)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Tip: For best results, ensure handwriting is clear and well-lit',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Scan button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _showImageSourceDialog,
                icon: const Icon(Icons.document_scanner, size: 30),
                label: const Text(
                  'Scan Document',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Status and progress indicator
              if (_isProcessing) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 10),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Extracted text section
              if (_extractedText.isNotEmpty) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Extracted Text:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          if (_isHandwritingMode)
                            Tooltip(
                              message: 'Handwriting recognition confidence: ${(_handwritingConfidence * 100).toStringAsFixed(0)}%',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getConfidenceColor(_handwritingConfidence),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(_handwritingConfidence * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          minLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Extracted text will appear here...',
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.5,
                            color: Colors.black87,
                            fontFamily: _isHandwritingMode ? 'Roboto' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _textController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Text copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SmartScanResultScreen(
                                    extractedText: _textController.text,
                                    isHandwritingMode: _isHandwritingMode,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Clear the extracted text and reset the UI
                              setState(() {
                                _extractedText = '';
                                _textController.clear();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('New Scan'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence < 0.5) return Colors.red;
    if (confidence < 0.7) return Colors.orange;
    if (confidence < 0.9) return Colors.yellow;
    return Colors.green;
  }
  
  // Enhanced image preprocessing for better OCR
  Future<File> _enhanceImageForOCR(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        debugPrint('Image decoding failed, returning original image');
        return imageFile; // Return original if decoding fails
      }
      
      // Apply basic image enhancements - keeping it simple to avoid compatibility issues
      img.Image processedImage = img.copyResize(image, width: image.width, height: image.height);
      
      // Convert to grayscale for better OCR - this is the most important step for text recognition
      processedImage = img.grayscale(processedImage);
      
      // Create a temporary file to save the processed image
      final tempDir = await Directory.systemTemp.createTemp('ocr_');
      final tempFile = File('${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Save the processed image
      await tempFile.writeAsBytes(img.encodeJpg(processedImage, quality: 100));
      
      debugPrint('Image enhanced successfully: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      debugPrint('Error enhancing image: $e');
      return imageFile; // Return original if processing fails
    }
  }

  // Advanced handwriting-specific corrections
  String _applyAdvancedHandwritingCorrections(String text) {
    if (text.isEmpty) return text;
    
    // Apply more aggressive handwriting-specific corrections
    
    // 1. Fix common letter confusions in handwriting
    Map<String, String> letterCorrections = {
      'cl': 'd',
      'rn': 'm',
      'vv': 'w',
      'lT': 'lt',
      'rnm': 'mm',
      'ii': 'u',
      'ri': 'n',
      'l1': 'h',
      '0': 'o',
      '1': 'l',
      '5': 's',
      '8': 'B',
      '6': 'b',
      '9': 'g',
    };
    
    String corrected = text;
    
    // Apply corrections with word boundary awareness
    letterCorrections.forEach((wrong, right) {
      // Only apply within words, not at word boundaries
      corrected = corrected.replaceAll(RegExp('(?<=\\w)$wrong(?=\\w)'), right);
    });
    
    // 2. Fix common word patterns in handwriting
    corrected = _correctCommonWords(corrected);
    
    // 3. Apply context-aware corrections
    corrected = _applyContextAwareCorrections(corrected);
    
    return corrected;
  }
  
  // Context-aware corrections that consider surrounding words
  String _applyContextAwareCorrections(String text) {
    // Split text into words
    List<String> words = text.split(RegExp(r'\s+'));
    if (words.length <= 1) return text;
    
    // Common word pairs and phrases that often appear together
    Map<String, Map<String, String>> contextCorrections = {
      'tlie': {'following': 'the', 'same': 'the', 'first': 'the'},
      'witli': {'the': 'with', 'a': 'with', 'my': 'with'},
      'tliat': {'is': 'that', 'was': 'that', 'are': 'that'},
      'liere': {'is': 'here', 'are': 'here'},
      'tliis': {'is': 'this', 'was': 'this'},
      'liave': {'to': 'have', 'not': 'have', 'been': 'have'},
    };
    
    // Apply context corrections with better efficiency
    for (int i = 0; i < words.length; i++) {
      String currentWord = words[i].toLowerCase();
      
      // Check if this word has potential context corrections
      if (contextCorrections.containsKey(currentWord)) {
        Map<String, String>? corrections = contextCorrections[currentWord];
        if (corrections == null) continue;
        
        // Check previous word (if exists)
        if (i > 0) {
          String prevWord = words[i-1].toLowerCase();
          String? replacement = corrections[prevWord];
          if (replacement != null) {
            words[i] = _preserveCase(words[i], replacement);
            continue;
          }
        }
        
        // Check next word (if exists)
        if (i < words.length - 1) {
          String nextWord = words[i+1].toLowerCase();
          String? replacement = corrections[nextWord];
          if (replacement != null) {
            words[i] = _preserveCase(words[i], replacement);
          }
        }
      }
    }
    
    return words.join(' ');
  }
  
  // Helper to preserve the case pattern when replacing words
  String _preserveCase(String original, String replacement) {
    if (original.isEmpty || replacement.isEmpty) return replacement;
    
    // If original is all uppercase, make replacement all uppercase
    if (original == original.toUpperCase()) {
      return replacement.toUpperCase();
    }
    
    // If original is capitalized, capitalize the replacement
    if (original[0] == original[0].toUpperCase()) {
      return replacement[0].toUpperCase() + replacement.substring(1);
    }
    
    return replacement;
  }
}
