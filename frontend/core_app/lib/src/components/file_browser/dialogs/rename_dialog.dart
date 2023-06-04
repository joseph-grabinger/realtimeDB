import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// A dialog to rename a file or folder.
class RenameDialog extends StatelessWidget {
  final String path;
  final String filename;
  final bool isFile;

  RenameDialog({
    Key? key,
    required this.path,
    required this.filename,
    required this.isFile,
  }) : super(key: key) {
    textController = TextEditingController(text: filename);

    // get filename without extension so it can be selected
    var parts = filename.split('.');
    parts.removeLast();

    String nameWithoutExt = parts.join('.');

    focusNode.addListener(() {
      if(focusNode.hasFocus && firstSelection) {
        textController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameWithoutExt.length);
        firstSelection = false;
      }
    });
  }

  final homeController = Get.find<HomeController>();

  late final TextEditingController textController;
  final FocusNode focusNode = FocusNode();

  bool firstSelection = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            padding: EdgeInsets.symmetric(
              vertical: homeController.isMobile ? 0.0 : 8.0,
              horizontal: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Abbrechen', maxLines: 1),
                    ),
                  ),
                ),
                const Text('Name wählen',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        if (isFile) {
                          String ext = filename.split('.').last;
                          String? txtExt = textController.text.split('.').last;
                          if (ext != txtExt) {
                            textController.text += '.$ext';
                          }
                        }

                        //Get.back();
                        String name = filename;
                        if (!isFile) {
                          name += '/';
                        }
                        bool success = await homeController.renameFile(
                            path.substring(1)+name, textController.text);

                        Navigator.of(context).pop(success ? textController.text : '');

                      },
                      child: const Text('Fertig', maxLines: 1),
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
                Icon(
                  isFile ? Icons.file_present : Icons.folder,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      autofocus: true,
                      controller: textController,
                      focusNode: focusNode,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte einen Namen eingeben';
                        }
                        if (value.contains('/')) {
                          return 'Der Name darf keine "/" enthalten';
                        }
                        if (value.contains('\\')) {
                          return 'Der Name darf keine "\\" enthalten';
                        }
                        if (value.contains('+')) {
                          return 'Der Name darf keine "+" enthalten';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Name',
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
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
