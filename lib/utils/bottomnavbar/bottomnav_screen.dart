import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/provider/bottomnavprovider/bottomnav_provider.dart';
import 'package:svareign/utils/bottomnavbar/bottomnavbar.dart';
import 'package:svareign/view/screens/addworkuserscreen/add_work_user_screen.dart';
import 'package:svareign/view/screens/adspostinscreen/ads_posting_screen.dart';
import 'package:svareign/view/screens/homescreen/homescreen.dart';
import 'package:svareign/view/screens/profilescreen/profile_screen.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({super.key});

  static final List<Widget> _screens = [
    Homescreen(),
    AddWorkUserScreen(),
    AdsPostingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomnavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          body: IndexedStack(index: nav.currentIndex, children: _screens),

          bottomNavigationBar: const Bottomnavbar(),
        );
      },
    );
  }
}
