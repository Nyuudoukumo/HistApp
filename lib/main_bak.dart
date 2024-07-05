import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? uint8list;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bytes = await rootBundle.load('assets/images/night.jpg');
      uint8list = bytes.buffer.asUint8List();
      setState(() {});
    });
  }

  void _blurImage() {
    setState(() {
      uint8list = blur(uint8list!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Image(image: MemoryImage(uint8list!)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _blurImage,
        tooltip: 'Blur',
        child: const Icon(Icons.image_aspect_ratio),
      ),
    );
  }

  /// 高斯模糊
  static Uint8List? blur(Uint8List list) {
    /// 深拷贝图片
    Pointer<Uint8> bytes = malloc.allocate<Uint8>(list.length);
    for (int i = 0; i < list.length; i++) {
      bytes.elementAt(i).value = list[i];
    }
    // 为图片长度分配内存
    final imgLengthBytes = malloc.allocate<Int32>(1)..value = list.length;

    // 查找 C++ 中的 opencv_blur() 函数
    final DynamicLibrary opencvLib = Platform.isAndroid
        ? DynamicLibrary.open("libnative-lib.so")
        : DynamicLibrary.process();
    final Pointer<Uint8> Function(
            Pointer<Uint8> bytes, Pointer<Int32> imgLengthBytes, int kernelSize)
        blur = opencvLib
            .lookup<
                NativeFunction<
                    Pointer<Uint8> Function(
                        Pointer<Uint8> bytes,
                        Pointer<Int32> imgLengthBytes,
                        Int32 kernelSize)>>("opencv_blur")
            .asFunction();

    /// 调用高斯模糊
    final newBytes = blur(bytes, imgLengthBytes, 15);
    if (newBytes == nullptr) {
      print('高斯模糊失败');
      return null;
    } else {
      print('高斯模糊成功');
    }

    var newList = newBytes.asTypedList(imgLengthBytes.value);

    /// 释放指针
    malloc.free(bytes);
    malloc.free(imgLengthBytes);
    return newList;
  }
}
