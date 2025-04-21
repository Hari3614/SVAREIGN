import 'package:flutter/material.dart';

class Elevatedbuttonwidget extends StatelessWidget {
  final void Function() onpressed;
  final double widht;
  final double? textsize;
  final String buttontext;
  final Color? color;
  final double height;

  const Elevatedbuttonwidget({
    super.key,
    required this.onpressed,
    required this.widht,
    required this.height,
    this.textsize,
    this.color,
    required this.buttontext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widht,
      height: height,
      child: ElevatedButton(
        onPressed: onpressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          buttontext,
          style: TextStyle(
            fontSize: textsize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
