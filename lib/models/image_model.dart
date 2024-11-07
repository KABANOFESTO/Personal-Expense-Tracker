import 'package:hive/hive.dart';

// This part directive allows Hive to generate the adapter code in 'image_model.g.dart'.
part 'image_model.g.dart'; // Ensure this is the correct path based on where the file is located

@HiveType(typeId: 0)
class ImageModel {
  @HiveField(0)
  final String path;

  ImageModel(this.path);
  
}
