import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:realtime_api/realtime_api.dart';

class DeleteProjectDialog extends StatelessWidget {
  final DatabaseReference dbRef;
  final String name;

  const DeleteProjectDialog({
    required this.dbRef,
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Text("Delete Project"),
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
        height: 120,
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
                  Text("The entire project, including all data, will be deleted permanently",
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text("Project: ",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(name),
              ],
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
            RealtimeDatabase.deleteProject(name).then((_) {
              Navigator.of(context).pop(true);
            });
            
          },
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
        ),
      ],
    );
  }
}
