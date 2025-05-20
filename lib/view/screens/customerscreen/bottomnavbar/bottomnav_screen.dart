import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnavbar.dart';
import 'package:svareign/view/screens/customerscreen/addworkuserscreen/add_work_user_screen.dart';
import 'package:svareign/view/screens/customerscreen/adspostinscreen/ads_posting_screen.dart';
import 'package:svareign/view/screens/customerscreen/homescreen/homescreen.dart';
import 'package:svareign/view/screens/customerscreen/profilescreen/profile_screen.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({super.key});

  static final List<Widget> _screens = [
    HomeScreen(),
    AddWorkUserScreen(),
    AdsPostingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomnavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(index: nav.currentIndex, children: _screens),

          bottomNavigationBar: const Bottomnavbar(),
        );
      },
    );
  }
}
