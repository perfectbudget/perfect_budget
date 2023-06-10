import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../constant/env.dart';

Future<String?> uploadFile(BuildContext context,
    {required Uint8List uint8list}) async {
  AppWidget.showLoading(context: context);
  String? image;
  final dataBuffer = FormData.fromMap(<String, dynamic>{
    'upload': MultipartFile.fromBytes(uint8list,
        filename: DateTime.now().toIso8601String()),
  });

  final Dio dio = Dio(BaseOptions(
    contentType: 'application/json',
  ));
  try {
    await dio
        .post<dynamic>(EnvValue.uploadImage, data: dataBuffer)
        .then((Response response) {
      if (response.data['files'].isNotEmpty) {
        image = response.data['files'].first['transforms'].first['location'];
      }
    });
    Navigator.of(context).pop();
    return image!;
  } catch (e) {
    Navigator.of(context).pop();
    return null;
  }
}
