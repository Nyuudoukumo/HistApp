import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Path {
  String? grayPath;
  String? histPath;

  Path();
  Future<void> initialize() async {
    await _getDocumentsDirectory();
    //_deleteCache();
  }

  void _deleteCache() async {
    File file = File(grayPath!);
    bool exists = await file.exists();
    if (exists) {
      await file.delete();
    }
    file = File(histPath!);
    exists = await file.exists();
    if (exists) {
      await file.delete();
    }
  }

  Future<void> _getDocumentsDirectory() async {
    //临时图片路径
    String? path;
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = documentsDirectory.path;
      //tempPath = '$path/temp.jpg';
      grayPath = '$path/gray.jpg';
      histPath = '$path/hist.jpg';
      //_deleteCache();
    } catch (e) {
      print('获取文档目录失败: $e');
    }
  }
}
