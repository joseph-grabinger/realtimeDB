import 'package:filestorage_api/filestorage_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:realtime_api/realtime_api.dart';

import '../models.dart';

class RenameProjectDialog extends StatelessWidget {
  final Project project;

  RenameProjectDialog({
    required this.project, 
    super.key,
  });

  final _formKey = GlobalKey<FormState>();
  String? newName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Rename Project"),
          const Spacer(),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
      content: SizedBox(
        height: 135,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Colors.red.shade900,
                  ),
                  const SizedBox(width: 10),
                  Text("Renaming the project might have side effects",
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "New Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) => newName = value,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              )
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 50),
      actions: [
        CupertinoButton(
            onPressed: Navigator.of(context).pop,
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
        ),
        CupertinoButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            if (project.type == ProjectType.realtimeDatabase) {
              RealtimeDatabase.updateProject(project.name, newName!).then((_) {
                Navigator.of(context).pop(newName);
              });
            } else if (project.type == ProjectType.fileStorage) {
              // TODO 
              // FileStorage.updateProject(project.name, newName!).then((_) {
              //   Navigator.of(context).pop(newName);
              // });
            }
          },
          child: Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text("Rename",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
