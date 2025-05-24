import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';
import 'package:svareign/firebase_options.dart';
import 'package:svareign/viewmodel/authprovider/serviceprovider/service_authprovider.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/addworkprovider.dart';
import 'package:svareign/viewmodel/bottomnavprovider/bottomnav_provider.dart';
import 'package:svareign/view/screens/splashscreen/splashscreen.dart';
import 'package:svareign/viewmodel/customerprovider/customer/profile_view_model.dart';
import 'package:svareign/viewmodel/customerprovider/userrequestprovider/userrequestprovider.dart';
import 'package:svareign/viewmodel/locationprovider/user_location_provider.dart';
import 'package:svareign/viewmodel/loginformprovider/login_formprovider.dart';
import 'package:svareign/viewmodel/passwordvisiblity/password_visiblity_provider.dart';
import 'package:svareign/viewmodel/service_provider/Serviceproivdereqst/servicereqsrprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';
import 'package:svareign/viewmodel/signupformprovider/form_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Splashscreen());
  }
}
