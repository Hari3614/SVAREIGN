import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';

class Custombottomnavbar extends StatelessWidget {
  const Custombottomnavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(70),
        child: BottomAppBar(
          color: kblackcolor,
          elevation: 20,
          height: 60,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,

          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navitem(context, icon: Icons.home, index: 0),
                _navitem(context, icon: Icons.add_task_outlined, index: 1),
                _navitem(context, icon: Icons.campaign, index: 2),
                _navitem(context, icon: Icons.person, index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navitem(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {
    final nav = Provider.of<BottomnavProvider>(context);
    final provider = Provider.of<BottomnavProvider>(context, listen: false);
    return IconButton(
      iconSize: 25,
      onPressed: () => provider.changeIndex(index),
      icon: Icon(
        icon,
        color: nav.currentIndex == index ? Colors.green : Colors.grey,
      ),
    );
  }
}
