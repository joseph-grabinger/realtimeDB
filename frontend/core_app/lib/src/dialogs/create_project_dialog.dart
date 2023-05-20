import 'package:core_api/core_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  String? projectName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Create Project"),
          const Spacer(),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Form(
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
          child: Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text("Create",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            await RealtimeDatabase.createProject(projectName!).then(
              (_) => Navigator.of(context).pop(projectName));
          },
        ),
      ],
    );
  }
}

