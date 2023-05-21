import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

import 'package:file_picker/file_picker.dart';

class ImportProjectDialog extends StatefulWidget {
  const ImportProjectDialog({super.key});

  @override
  State<ImportProjectDialog> createState() => _ImportProjectDialogState();
}

class _ImportProjectDialogState extends State<ImportProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  bool error = false;

  String? projectName;
  File? file;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Import Project"),
          const Spacer(),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project name',
                border: OutlineInputBorder(),
              ),
              onChanged: (String value) => projectName = value,
              validator: (String? value) {
                if (value == null || value.isEmpty) return 'Project name must not be empty';
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: file != null ? Text(file!.path) : error ? const Text("No file selected",
                    style: TextStyle(color:Colors.red)) : Container(),
                ),
                CupertinoButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom, 
                      allowedExtensions: ['json'],
                    );

                    if (result != null) {
                      setState(() {
                        file = File(result.files.single.path!);
                        error = false;
                      });
                    }
                  },
                  child: const Text("Select file"),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(left: 50),
      actions: [
        CupertinoButton(
            child: Container(
              width: 100,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Text("Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
        ),
        CupertinoButton(
          onPressed: _onImportProjectPressed,
          child: Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text("Import",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onImportProjectPressed() async {
    if (file == null) {
      setState(() {
        error = true;
      });
    }
    if (!_formKey.currentState!.validate()) return;

    var data = await file!.readAsString();
    Map json = convert.jsonDecode(data);

    await RealtimeDatabase.createProject(projectName!, json).then(
      (_) => Navigator.of(context).pop(projectName));
  }
}
