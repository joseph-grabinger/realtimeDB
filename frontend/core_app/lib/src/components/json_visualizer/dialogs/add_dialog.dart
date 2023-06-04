import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:realtime_api/realtime_api.dart';

class AddDialog extends StatefulWidget {
  final DatabaseReference dbRef;
  final Map data;

  const AddDialog({
    required this.dbRef,
    required this.data,
    super.key,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _formKey = GlobalKey<FormState>();

  String? key;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Add Data"),
          const Spacer(),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Storage location of data",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Text("/${widget.dbRef.path}"),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Key',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a key';
                  }
                  if (widget.data.containsKey(value)) {
                    return 'Key already exists';
                  }
                  return null;
                },
                onChanged: (String value) => key = value,
              ),
            ),
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
          child: Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text("Add",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          onPressed: () {
            // dbRef TODO
            if (!_formKey.currentState!.validate()) return;

            widget.dbRef.child(key!).set("NULL");

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
