import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../file_browser_controller.dart';

/// A dialog to delete a file or a folder and its contents.
class DeleteDialog extends StatelessWidget {
  final String path;
  final String filename;

  DeleteDialog({
    Key? key,
    required this.path,
    required this.filename,
  }) : super(key: key);

  final controller = Get.find<FileBrowserController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 291,
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Daten löschen',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700]),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text('Alle Daten an diesem Speicherort werden endgültig gelöscht!',
                        maxLines: 2,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              const Text('Name:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(filename),
              const SizedBox(height: 8.0),
              const Text('Speicherort der Daten:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(path),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Get.back(),
                    child: const Text('Abbrechen',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () async {
                      await controller.fileStorage.deleteFile(path, filename);
                      Get.back();
                    },
                    child: const Text('Löschen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
