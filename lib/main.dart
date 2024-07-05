import 'package:flutter/material.dart';
import '/pages/Menu_Page.dart';
import '/pages/intro_page.dart';
import '/pages/history_page.dart';
import '/pages/home_page.dart';
import '/utility/get_path.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class FileProvider with ChangeNotifier {
  Uint8List? showGray;
  Uint8List? showHist;

  Uint8List? get showG => showGray;
  Uint8List? get showH => showHist;

  void change(Uint8List gray, Uint8List hist) {
    showGray = gray;
    showHist = hist;
    notifyListeners(); // 通知依赖的小部件更新
  }
}

Path path = Path();
File? gray_img;
File? hist_img;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await path.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: IntroPage(),
      routes: {
        '/intropage': (context) => const IntroPage(),
        '/menupage': (context) => const MenuPage(),
        '/historypage': (context) => HistoryPage(),
        '/homepage': (context) => const HomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
