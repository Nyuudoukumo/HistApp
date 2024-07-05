import 'package:flutter/material.dart';

class MyBotton extends StatefulWidget {
  final String text;
  final void Function()? onTap;
  final IconData? icon;

  const MyBotton({
    super.key,
    required this.text,
    required this.onTap,
    required this.icon,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyBotton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _updatePressedState(true),
        onTapUp: (_) => _updatePressedState(false),
        onTapCancel: () => _updatePressedState(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isPressed ? 290.0 : 300.0, // 动态变化的宽度
          height: _isPressed ? 55.0 : 60.0, // 动态变化的高度
          decoration: BoxDecoration(
            color: _isPressed ? Colors.grey[300] : Colors.white, // 按下时颜色变化
            borderRadius: BorderRadius.circular(40),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
              ),
              Text(
                widget.text,
                style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePressedState(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }
}
