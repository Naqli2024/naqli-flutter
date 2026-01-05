import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:easy_localization/easy_localization.dart'; // Assuming you are using easy_localization

class MyVectorImage extends StatelessWidget {
  final String name;
  final double height;

  const MyVectorImage({
    super.key,
    required this.name,
    required this.height,
  });

  static Future<void> preload(BuildContext context, String assetName) async {
    try {
      await AssetBytesLoader('assets/vectors/$assetName').loadBytes(context);
    } catch (e) {
      debugPrint('Error preloading asset assets/vectors/$assetName: $e'); // Optional error logging
    }
  }

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      loader: AssetBytesLoader('assets/vectors/$name'),
      height: height,
    );
  }
}