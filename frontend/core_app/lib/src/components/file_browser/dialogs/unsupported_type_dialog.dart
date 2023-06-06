import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class UnsupportedTypeDialog extends StatelessWidget {
  const UnsupportedTypeDialog({
    Key? key,
    required this.filename,
  }) : super(key: key);

  final String filename;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filename),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:  Icon(MdiIcons.fileCancel, size: 70),
            ),
            Text('${filename.split('.').last}-files are not supported.'),
          ],
        ),
      ),
    );
  }
}
