import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RoleSelectionPage extends StatelessWidget {
  final String title;
  final String imagpath;
  final VoidCallback ontap;
  const RoleSelectionPage({
    super.key,
    required this.title,
    required this.imagpath,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    // final height = MediaQuery.sizeOf(context).height;
    //final width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: ontap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Lottie.asset(
              imagpath,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
