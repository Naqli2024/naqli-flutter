import 'package:flutter/widgets.dart';
import 'dart:math';

class ViewUtil {
  final BuildContext context;

  ViewUtil(this.context);

  bool get isTablet {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    return diagonal > 1100;
  }
}
