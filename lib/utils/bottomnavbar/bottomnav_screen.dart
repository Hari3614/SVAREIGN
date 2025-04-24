import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/provider/bottomnavprovider/bottomnav_provider.dart';
import 'package:svareign/utils/bottomnavbar/bottomnavbar.dart';
import 'package:svareign/view/screens/homescreen/homescreen.dart';
import 'package:svareign/view/screens/profilescreen/profile_screen.dart';
import 'package:svareign/view/screens/settingscreen/settingscreen.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({super.key});

  static final List<Widget> _screens = [
    Homescreen(),
    ProfileScreen(),
    Settingscreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomnavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          body: IndexedStack(index: nav.currentIndex, children: _screens),

          bottomNavigationBar: const Bottomnavbar(),

          //   floatingActionButton: FloatingActionButton(
          //     onPressed: () {
          //       /* ... */
          //     },
          //     child: const Icon(Icons.add),
          //   ),
          //   floatingActionButtonLocation:
          //       FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
