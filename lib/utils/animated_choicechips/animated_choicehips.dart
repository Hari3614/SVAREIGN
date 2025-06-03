import 'package:flutter/material.dart';

class AnimatedChoicehips extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback ontap;
  const AnimatedChoicehips({
    super.key,
    required this.label,
    required this.selected,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
                : [],
      ),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(20),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
