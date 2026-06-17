import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_themes.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';
import 'package:svareign/firebase_options.dart';
import 'package:svareign/viewmodel/authprovider/serviceprovider/service_authprovider.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/addworkprovider.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';
import 'package:svareign/view/screens/splashscreen/splashscreen.dart';
import 'package:svareign/viewmodel/customerprovider/bookingprovider/bookingprovider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/customerprovider/customer/profile_view_model.dart';
import 'package:svareign/viewmodel/customerprovider/searchprovider/searchprovider.dart';
import 'package:svareign/viewmodel/customerprovider/userrequestprovider/userrequestprovider.dart';
import 'package:svareign/viewmodel/customerprovider/fetchserviceprovider/fetserviceprovider.dart';
import 'package:svareign/viewmodel/locationprovider/user_location_provider.dart';
import 'package:svareign/viewmodel/loginformprovider/login_formprovider.dart';
import 'package:svareign/viewmodel/passwordvisiblity/password_visiblity_provider.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/reviewprovider/reviewprovider.dart';
import 'package:svareign/viewmodel/service_provider/Serviceproivdereqst/servicereqsrprovider.dart';
import 'package:svareign/viewmodel/service_provider/booknndfetchprovider/ordersfromuserprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';
import 'package:svareign/viewmodel/service_provider/jobstatprovider/jobstatprovider.dart';
import 'package:svareign/viewmodel/service_provider/serviceprofileprovider/serviceprofileprovider.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';
import 'package:svareign/viewmodel/customerprovider/servicepostprovider/servicepostprovider.dart';
import 'package:svareign/viewmodel/signupformprovider/form_provider.dart';
import 'package:svareign/viewmodel/notification/notification_provider.dart';
import 'package:svareign/viewmodel/themeprovider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authprovider()),
        ChangeNotifierProvider(create: (_) => BottomnavProvider()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => PasswordVisiblityProvider()),
        ChangeNotifierProvider(create: (_) => Signupformprovide()),
        ChangeNotifierProvider(create: (_) => LoginFormprovider()),
        ChangeNotifierProvider(create: (_) => ServiceAuthprovider()),
        ChangeNotifierProvider(create: (_) => Workprovider()),
        ChangeNotifierProvider(create: (_) => UserLocationProvider()),
        ChangeNotifierProvider(create: (_) => Profileprovider()),
        ChangeNotifierProvider(create: (_) => Jobpostprovider()),
        ChangeNotifierProvider(create: (_) => Servicereqsrprovider()),
        ChangeNotifierProvider(create: (_) => Userrequestprovider()),
        ChangeNotifierProvider(create: (_) => Jobadsprovider()),
        ChangeNotifierProvider(create: (_) => Jobstatprovider()),
        // ChangeNotifierProvider(create: (_) => Providerpayment()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => Availablityservice()),
        ChangeNotifierProvider(create: (_) => Cartprovider()),
        ChangeNotifierProvider(create: (_) => Bookingprovider()),
        ChangeNotifierProvider(create: (_) => Ordersfromuserprovider()),
        ChangeNotifierProvider(create: (_) => Serviceprofileprovider()),
        //ChangeNotifierProvider(create: (_) => Appstate()),
        ChangeNotifierProvider(create: (_) => Searchprovider()),
        ChangeNotifierProvider(create: (_) => ServicePostProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ChangeNotifierProvider(create: (_) => Upiredirectprovider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF0D0D2B) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Splashscreen(),
    );
  }
}
