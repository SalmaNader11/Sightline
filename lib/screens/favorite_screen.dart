import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favoriteFiles;
  final Function(String) onAddFavorite;

  FavoritesScreen({required this.favoriteFiles, required this.onAddFavorite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite Files',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: favoriteFiles.isEmpty
                ? Center(child: Text('No favorite files yet.'))
                : ListView.builder(
              itemCount: favoriteFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      favoriteFiles[index],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}