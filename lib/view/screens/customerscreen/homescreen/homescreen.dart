import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/viewmodel/themeprovider/theme_provider.dart';
import 'widgets/home_helpers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Home",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: themeProvider.isDark ? kSecondaryAccent : Colors.green,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: HomeHelpersScreen(),
    );
  }
}
