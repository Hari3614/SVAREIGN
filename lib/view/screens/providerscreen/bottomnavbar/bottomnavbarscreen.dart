import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/addcommonscreen/addcommonscreen.dart';

import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbar.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/home_screen.dart';
import 'package:svareign/view/screens/providerscreen/profilescreen/profilescreen.dart';
import 'package:svareign/view/screens/providerscreen/serviceworkscreen/serviceworkscreen.dart';
import 'package:svareign/view/screens/providerscreen/servicepostscreen/servicepostscreen.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';

class Servicehomecontainer extends StatelessWidget {
  const Servicehomecontainer({super.key});
  static final List<Widget> _screens = [
    DummyScreen(),
    ServiceProviderHome(),
    Serviceadscreen(),
    Addcommonscreen(),
    Serviceprofilesceen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomnavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(index: nav.currentIndex, children: _screens),
          bottomNavigationBar: Custombottomnavbar(),
        );
      },
    );
  }
}
