import 'package:flutter/material.dart';

class Textfieldwidget extends StatelessWidget {
  final TextEditingController controller;
  final IconData? suffixicon;
  final String? Function(String?)? validator;
  final IconData? preffixicon;
  final String? hinttext;
  final String labeltext;
  final TextInputType? inputType;
  final bool obscuretext;
  final Color? color;
  final bool? filled;
  final String? errortext;
  const Textfieldwidget({
    super.key,
    required this.controller,
    this.validator,
    this.suffixicon,
    this.preffixicon,
    this.hinttext,
    required this.labeltext,
    this.inputType,
    required this.obscuretext,
    this.color,
    this.filled,
    this.errortext,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final widht = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: widht * 0.9,
      child: TextField(
        controller: controller,
        keyboardType: inputType ?? TextInputType.text,
        decoration: InputDecoration(
          label: Text(labeltext, style: TextStyle(color: color, fontSize: 16)),
          hintText: hinttext,
          hintStyle: TextStyle(color: color),
          prefixIcon:
              preffixicon != null ? Icon(preffixicon, color: color) : null,
          suffixIcon:
              suffixicon != null
                  ? IconButton(
                    icon: Icon(suffixicon),
                    color: color,
                    onPressed: () {},
                  )
                  : null,
          errorText: errortext,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), // rounded corners
            borderSide: BorderSide(color: color ?? Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: color ?? Colors.grey, width: 2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          fillColor: color,
          filled: filled,
        ),
      ),
    );
  }
}
