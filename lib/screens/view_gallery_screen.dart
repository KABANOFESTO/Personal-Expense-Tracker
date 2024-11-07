import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import '../models/image_model.dart';

class ViewGalleryScreen extends StatelessWidget {
  Future<List<File>> fetchImagesFromHive() async {
    final box = await Hive.openBox<ImageModel>('imageBox');
    final images = box.values.toList();

    return images.map((image) => File(image.path)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Gallery'),
      ),
      body: FutureBuilder<List<File>>(
        future: fetchImagesFromHive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error fetching images!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final images = snapshot.data;

          if (images == null || images.isEmpty) {
            return const Center(
              child: Text(
                'No images to display!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.file(
                images[index],
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
    );
  }
}
