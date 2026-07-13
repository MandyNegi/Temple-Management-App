import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:temple/firebase_options.dart';
import 'package:temple/routes/route_helper.dart';
import 'package:temple/services/auth_service.dart'; // Import your phone authentication service file
import 'package:temple/utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialise Firebase Platform Assets
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Inject your Authentication background state routing thread immediately on app load
  Get.put(AuthService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Preserving your layout portrait strictness profiles
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // System overlay rule to keep system status bar/buttons blending perfectly with your layout
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temple',
      // Kept your Splash View as the initial entry checkpoint
      initialRoute: RouteHelper.getSplashPage(), 
      getPages: RouteHelper.routes,
      theme: ThemeData(
        primaryColor: AppColors.mainColor,
        // Tinting standard theme data to match the bright orange temple layout color accents
        primarySwatch: Colors.orange, 
        fontFamily: "Lato",
      ),
    );
  }
}
