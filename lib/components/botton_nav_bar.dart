import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    //margin:const EdgeInsets.all(25);
    return GNav(
        onTabChange: (value) => onTabChange!(value),
        color: Color.fromARGB(255, 18, 89, 68),
        mainAxisAlignment: MainAxisAlignment.center,
        activeColor: Color.fromARGB(255, 18, 89, 68),
        tabBackgroundColor: Colors.grey.shade300,
        tabBorderRadius: 24,
        tabActiveBorder: Border.all(color: Colors.white),
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.photo,
            text: 'Result',
          )
        ]);
  }
}
