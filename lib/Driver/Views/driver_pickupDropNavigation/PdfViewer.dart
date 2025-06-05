import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileDownloader {
  static Future<void> downloadAndOpenFile(BuildContext context, String url, String fileName) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = "${tempDir.path}/$fileName";
      Dio dio = Dio();
      print(url);
      await dio.download(url, filePath);
      OpenFile.open(filePath);
    } catch (e) {
      CommonWidgets().showToast("File not found");
    }
  }
}
