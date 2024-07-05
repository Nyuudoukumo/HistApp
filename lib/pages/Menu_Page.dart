import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/components/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';
import 'package:tuple/tuple.dart';
import '/main.dart';
import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
//实例化选择图片
  final ImagePicker picker = new ImagePicker();
  File? _userImage;
//图片字节流
  Uint8List? uint8list;
  Uint8List? histlist;

//异步吊起相机拍摄新照片方法
  Future _getCameraImage() async {
    final cameraImages = await picker.pickImage(source: ImageSource.camera);
    if (mounted) {
      setState(() {
        //拍摄照片不为空
        if (cameraImages != null) {
          _userImage = File(cameraImages.path);
          print('你选择的路径是：${_userImage.toString()}');
          //图片为空
        } else {
          print('没有照片可以选择');
        }
      });
    }
  }

  Future _getImage() async {
    //选择相册
    final pickerImages = await picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        if (pickerImages != null) {
          _userImage = File(pickerImages.path);
          print('你选择的本地路径是：${_userImage.toString()}');
        } else {
          print('没有照片可以选择');
        }
      });
    }
  }

  //清除图片缓存
  Future<void> evictImage(String path) async {
    final imageProvider = FileImage(File(path));
    await imageProvider.evict();
  }

  void _getGrayImage() async {
    if (_userImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("提示"),
            content: const Text("请先选择一张图片"),
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
      return;
    }
    File file = _userImage!; //File(tempPath!);
    bool fileExists = await file.exists();
    if (!fileExists) {
      print("文件为空");
      return;
    }

    final bytes = await file.readAsBytes();
    uint8list = bytes.buffer.asUint8List();
    //Uint8List grayList = gray(uint8list!)!;

    Tuple3 temp = gray(uint8list!); //将图片灰度化
    Uint8List? grayList = temp.item1;
    Uint8List? histList = temp.item2;
    String? duration = temp.item3.toString();
    if (grayList == null) {
      return;
    }

    String? grayPath;
    String? histPath;
    if (path.grayPath != null) {
      grayPath = path.grayPath!;
    } else {
      return;
    }
    if (path.histPath != null) {
      histPath = path.histPath!;
    } else {
      return;
    }

    //将灰度化后的图片保存
    gray_img = File(grayPath);
    await gray_img!.writeAsBytes(grayList!);
    await evictImage(grayPath);
    hist_img = File(histPath);
    await hist_img!.writeAsBytes(histList!);
    await evictImage(histPath);
    Provider.of<FileProvider>(context, listen: false)
        .change(grayList, histList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("提示"),
          content: Text("处理完成，用时${duration}ms,请在点击下方导航查看结果"),
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

  //灰度化
  static Tuple3 gray(Uint8List list) {
    //static Uint8List? gray(Uint8List list) {
    /// 深拷贝图片
    Pointer<Uint8> bytes = malloc.allocate<Uint8>(list.length);
    for (int i = 0; i < list.length; i++) {
      bytes.elementAt(i).value = list[i];
    }

    // 为图片长度分配内存
    final imgLengthBytes = malloc.allocate<Int32>(1)..value = list.length;
    final histLengthBytes = malloc.allocate<Int32>(1)..value = list.length;

    // 为直方图指针
    Pointer<Uint8> hist = malloc.allocate<Uint8>(300000);

    // 查找 C++ 中的 opencv_gray() 函数
    final DynamicLibrary opencvLib = Platform.isAndroid
        ? DynamicLibrary.open("libnative-lib.so")
        : DynamicLibrary.process();

    final Pointer<Uint8> Function(Pointer<Uint8> bytes,
            Pointer<Int32> imgLengthBytes, Pointer<Uint8> hist, Pointer<Int32> histLengthBytes)
        grayC = opencvLib
            .lookup<
                NativeFunction<
                    Pointer<Uint8> Function(
                        Pointer<Uint8> bytes,
                        Pointer<Int32> imgLengthBytes,
                        Pointer<Uint8> hist,
                        Pointer<Int32> histLengthBytes)>>(
              "opencv_gray",
            )
            .asFunction();

    /// 调用灰度化
    DateTime startTime = DateTime.now();

    final grayBytes = grayC(bytes, imgLengthBytes, hist, histLengthBytes);
    DateTime endTime = DateTime.now();
    int duration = endTime.difference(startTime).inMilliseconds;
    final histBytes = hist;
    if (grayBytes == nullptr) {
      print('灰度化失败');
      return Tuple3(null, null, null);
    } else {
      print('灰度化成功');
    }

    var grayList = grayBytes.asTypedList(imgLengthBytes.value);
    var histList = histBytes.asTypedList(histLengthBytes.value);
    print('拷贝成功');

    /// 释放指针
    malloc.free(bytes);
    malloc.free(imgLengthBytes);
    malloc.free(histLengthBytes);
    malloc.free(hist);
    //return grayList;
    return Tuple3(grayList, histList, duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 199, 199, 199),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 125, 160, 162),
        //shadowColor: ,
        title: Text(
          'Image Histogram',
          style: TextStyle(color: Colors.grey[900]),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //选择图片
          if (_userImage == null)
            Center(
                child: Image.asset(
              'lib/images/file.png',
              height: 400,
              width: 350,
            ))
          else
            Center(
                child: Image.file(
              _userImage!,
              height: 500,
              width: 350,
            )),

          //从手机文件中读取图片

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 100,
                child: MyBotton(
                    icon: Icons.photo_library,
                    text: '相册',
                    onTap: () {
                      _getImage();
                    }),
              ),
              const SizedBox(width: 20),
              SizedBox(
                height: 80,
                width: 100,
                child: MyBotton(
                    icon: Icons.camera_alt,
                    text: '拍照',
                    onTap: () {
                      _getCameraImage();
                    }),
              ),
              const SizedBox(width: 20),
              SizedBox(
                  height: 80,
                  width: 100,
                  child: MyBotton(
                      icon: Icons.call_to_action,
                      text: '生成',
                      onTap: () {
                        _getGrayImage();
                      })),
            ],
          ),
          //效果展示
        ],
      ),
    );
  }
}
