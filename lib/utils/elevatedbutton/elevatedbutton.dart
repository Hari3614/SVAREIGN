import 'package:flutter/material.dart';

class Elevatedbuttonwidget extends StatelessWidget {
  final void Function()? onpressed;
  final double widht;
  final double? textsize;
  final String buttontext;
  final Color? color;
  final double height;
  final bool isLoading;

  const Elevatedbuttonwidget({
    super.key,
    required this.onpressed,
    required this.widht,
    required this.height,
    this.textsize,
    this.color,
    required this.buttontext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widht,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onpressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
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
