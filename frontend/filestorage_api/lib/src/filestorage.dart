
import 'package:flutter/foundation.dart';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';

import 'models.dart';

class FileStorage {
  final String? project;

  FileStorage(this.project) {
    if (project == null) {
      throw("project must not be null");
    }
    if (project!.contains('/')) {
      throw("project must not contain '/' charters");
    }
  }

  static const String baseUrl = "http://localhost:5001/api/filestorage";

  final Dio dioClient = Dio(BaseOptions(baseUrl: baseUrl));

  /// Uploads files to the storage.
  Future<void> uploadFiles(List<XFile> files, path) async {
    for (XFile file in files) {
      final formData = FormData.fromMap({
        'path': path,
        'file': await MultipartFile.fromFile(file.path),
      });
      try {
        final res = await dioClient.post('/add',
          data: formData,
        );
        if (res.statusCode != 201) debugPrint('Upload failed!');
      } on DioError catch(e) {
        debugPrint(e as String?);
      }
    }
  }

  /// Gets the directory structure of the provided [path] from the storage.
  Future<FolderM?> getStructure(String path) async {
    try {
      final res = await dioClient.get('/get_structure/',
        queryParameters: {
          'path': path.substring(1), // remove leading slash
        });

      FolderM dir = FolderM.fromJson(res.data ?? {});
      if (res.statusCode == 200) return dir;
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
    return null;
  }

  /// Moves a file from [source] to [destination] in the storage.
  Future<void> moveFile(String filename, String source, String destination) async {
    try {
      final res = await dioClient.put('/move', data: {
        'filename': filename,
        'source': source.substring(1), // remove leading slash
        'destination': destination,
      });
      if (res.statusCode != 200) debugPrint('Move failed!');
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
  }

  /// Copies a file from [source] to [destination] in the storage.
  Future<void> copyFile(String source, String destination) async {
    try {
      final res = await dioClient.put('/copy', data: {
        'source': source.substring(1), // remove leading slash
        'destination': destination,
      });
      if (res.statusCode != 200) debugPrint('Copy failed!');
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
  }

  /// Renames a file in the storage.
  Future<bool> renameFile(String filepath, String newName) async {
    try {
      final res = await dioClient.put('/rename', data: {
        'filepath':  filepath,
        'new_name': newName,
      });
      if (res.statusCode == 200) return true;
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
    return false;
  }

  /// Deletes a file from the storage.
  Future<void> deleteFile(String path, String filename) async {
    try {
      final res = await dioClient.delete('/delete', data: {
        'filepath': path.substring(1) + filename,
      });
      if (res.statusCode != 200) debugPrint('Delete failed!');
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
  }

  /// Adds a folder to the storage.
  Future<bool> addFolder(String path, String name) async {
    try {
      final res = await dioClient.post('/share/add_folder', data: {
        'path': path.substring(1), // remove leading slash
        'name': name,
      });
      if (res.statusCode == 201) return true;
    } on DioError catch(e) {
      debugPrint(e as String?);
    }
    return false;
  }
}
