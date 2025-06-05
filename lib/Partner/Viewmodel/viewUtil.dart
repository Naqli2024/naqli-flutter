import 'package:flutter/widgets.dart';
import 'dart:math';

class ViewUtil {
  final BuildContext context;

  ViewUtil(this.context);

  bool get isTablet {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }
}

