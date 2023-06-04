import 'package:flutter/material.dart';

import 'package:get/get.dart';


class BackTextButton extends StatelessWidget {
  final String text;
  final bool goBack;
  final void Function()? additionalOnTap;

  const BackTextButton({
    Key? key,
    required this.text,
    this.goBack = true,
    this.additionalOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      if (goBack) {
        Get.back();
      }

      if (additionalOnTap != null) {
        additionalOnTap!();
      }
    },
    child: Row(
      children: [
        const Icon(Icons.chevron_left, color: Colors.blue),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(text, style: const TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}
