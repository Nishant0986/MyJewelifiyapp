import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageStorage {
  Future<String?> saveImage(File image, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName.jpg';
      await image.copy(imagePath);
      return imagePath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<File?> getImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error retrieving image: $e');
      return null;
    }
  }
}
