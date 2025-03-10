import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> recentFiles;

  HomeScreen({required this.recentFiles});

  void _changeFont() {
    // Placeholder for font change functionality
    print('Change Font button pressed');
  }

  void _textToSpeech() {
    // Placeholder for text-to-speech functionality
    print('Text to Speech button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Uploaded Files',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: recentFiles.isEmpty
                ? Center(child: Text('No recent files yet.'))
                : ListView.builder(
              itemCount: recentFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      recentFiles[index],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
          if (recentFiles.isNotEmpty) ...[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _changeFont,
                  child: Text('Change Font'),
                ),
                ElevatedButton(
                  onPressed: _textToSpeech,
                  child: Text('Text to Speech'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}