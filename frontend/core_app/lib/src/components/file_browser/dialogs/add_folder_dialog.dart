import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../others/custom_snackbar.dart';
import '../file_browser_controller.dart';

/// A dialog to add a folder.
class AddFolderDialog extends StatelessWidget {
  final String path;

  AddFolderDialog({
    Key? key,
    required this.path,
  }) : super(key: key);

  final TextEditingController textController = TextEditingController();

  final controller = Get.find<FileBrowserController>();
  
  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
        maxWidth: 500,
      ),
      child: Column(
        children: [
          Padding(
            padding: !controller.isMobile
                ? const EdgeInsets.all(8.0)
                : const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Cancel', maxLines: 1),
                    ),
                  ),
                ),
                const Text('New Folder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final bool success = await controller.fileStorage.addFolder(
                            path, textController.text);
                        if (success) {
                          // returns the created folder name
                          Get.back(result: textController.text);
                        } else {
                          showSnackbar('Error', 'Folder could not be created!');
                        }
                      },
                      child: const Text('Done', maxLines: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder, size: 100, color: Colors.grey),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    autofocus: true,
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Unnamed',
                      fillColor: Colors.grey[300],
                      filled: true,
                      focusColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
