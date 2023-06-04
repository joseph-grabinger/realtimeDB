import 'package:flutter/material.dart';

/// Calculates the item width within a [Wrap] widget, based on the provided [context].
/// If the screen is in portrait mode, [subtractWidth] will be subtracted
/// from the calculated width, else 170.0 will be returned.
double calculateItemWidth(BuildContext context, double subtractWidth) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  if (height > width) {
    return (width / 2) - subtractWidth;
  } else {
    return 170.0;
  }
}
