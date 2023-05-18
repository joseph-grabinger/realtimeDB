import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:core_api/database_reference.dart';

class DeleteDialog extends StatelessWidget {
  final DatabaseReference dbRef;

  const DeleteDialog({required this.dbRef, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Delete Data"),
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
                  Text(
                    "All data at this location, including nested data, will be deleted",
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Storage location of data",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Text("/${dbRef.path}"),
          ],
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
                child: Text(
                  "Cancel",
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
              color: Colors.red,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text("Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          onPressed: () {
            dbRef.remove();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
