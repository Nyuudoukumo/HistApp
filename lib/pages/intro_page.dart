import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 20, 131, 112),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              //APP type
              Text(
                "Image Histogram Calculations",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 25),
              //icon
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset('lib/images/design-process.png'),
              ),
              const SizedBox(height: 25),
              Text(
                "对图像进行灰度化处理并生成直方图",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 25,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 80),
              MyBotton(
                icon: Icons.arrow_forward,
                text: "Get Started !",
                onTap: () {
                  //GO TO menu page
                  Navigator.pushNamed(context, '/homepage');
                  print("testttwartawdawd");
                },
              )
            ],
          ),
        ));
  }
}

// class _IntroPageState extends State<IntroPage>{
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//     return Scaffold();
//   }
//
// }
