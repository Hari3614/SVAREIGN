import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';

class Bottomnavbar extends StatelessWidget {
  const Bottomnavbar({super.key});

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<BottomnavProvider>(context);
    //final height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(70),
        child: BottomAppBar(
          color: kblackcolor,
          elevation: 10,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          height: 60,
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(context, icon: Icons.home, index: 0),
                _navItem(context, icon: Icons.add_task_outlined, index: 1),
                _navItem(context, icon: Icons.campaign, index: 2),
                _navItem(context, icon: Icons.person_2, index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {
    final provider = Provider.of<BottomnavProvider>(context);
    final nav = Provider.of<BottomnavProvider>(context, listen: false);
    return IconButton(
      iconSize: 20,
      padding: EdgeInsets.zero,
      onPressed: () => nav.changeIndex(index),
      icon: Icon(
        icon,
        color: provider.currentIndex == index ? Colors.green : Colors.grey,
      ),
    );
  }
}
