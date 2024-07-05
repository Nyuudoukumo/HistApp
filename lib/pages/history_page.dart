import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/components/button.dart';
import '/main.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  Future<void> saveImage(
      BuildContext context, Uint8List showG, Uint8List showH) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      if (showG.isNotEmpty && showH.isNotEmpty) {
        final result1 = await ImageGallerySaver.saveImage(showG,
            name: "G${formattedDate}G");
        //final result2 = await ImageGallerySaver.saveImage(showH,name: "H${formattedDate}H");
        print("${formattedDate}");
        //print("result:$result1,$result2");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("提示"),
              content: const Text("下载成功"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("确定")),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("提示"),
            content: const Text("请求权限失败"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("确定")),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? showG = Provider.of<FileProvider>(context).showG;
    Uint8List? showH = Provider.of<FileProvider>(context).showH;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 199, 199, 199),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (gray_img == null || showG == null)
            Expanded(
                child: Center(
                    child: Image.asset(
              'lib/images/file.png',
              height: 450,
              width: 350,
            )))
          else
            Center(
              child: Image.memory(
                showG,
                height: 300,
                width: 350,
              ),
            ),
          if (hist_img == null || showH == null)
            Center(
                child: Image.asset(
              'lib/images/file.png',
              height: 200,
              width: 350,
            ))
          else
            Center(
              child: Image.memory(
                showH,
                height: 200,
                width: 350,
              ),
            ),
          /*Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyBotton(
                  icon: Icons.get_app,
                  text: "Download",
                  onTap: () {
                    saveImage(context, showG!, showH!);
                  },
                ),
              ],
            ),
          )*/
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 125, 160, 162),
        title: Text(
          'Result',
          style: TextStyle(color: Colors.grey[900]),
        ),
      ),
    );
  }
}
