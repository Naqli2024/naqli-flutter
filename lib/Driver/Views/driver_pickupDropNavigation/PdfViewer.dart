import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileDownloader {
  static Future<void> downloadAndOpenFile(BuildContext context, String url, String fileName) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = "${tempDir.path}/$fileName";
      Dio dio = Dio();
      await dio.download(url, filePath);
      OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }
}
