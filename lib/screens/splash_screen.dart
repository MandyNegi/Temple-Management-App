import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 Added to verify active credentials
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../routes/route_helper.dart';
import '../utils/dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

ListResult? result;
List<String> items = ['2018-2019'];

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  void putPdfNameInItem() {
    items.clear();
    result?.items.forEach((Reference ref) {
      items.add((ref.name).replaceAll('.pdf', ''));
    });
    print(items);
  }

  Future<void> listExample() async {
    try {
      result = await FirebaseStorage.instance
          .ref()
          .child('files')
          .listAll();

      result?.items.forEach((Reference ref) {
        print('Found file: ${ref.fullPath}');
      });

      result?.prefixes.forEach((Reference ref) {
        print('Found directory: ${ref.fullPath}');
      });
    } catch (e) {
      print("Error pre-loading files on splash: $e");
    }
  }

  @override
  void initState() {
    print(Dimensions.screenHeight);
    print(Dimensions.screenWidth);
    
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    
    // 🟢 FIXED: The timer now respects the active user session lifecycle instead of forcing home
    // Timer(const Duration(seconds: 3), () {
    //   if (FirebaseAuth.instance.currentUser == null) {
    //     // If no user is cached on the phone, send them safely to the mobile login screen
    //     Get.offAllNamed(RouteHelper.getLoginPage()); 
    //   } else {
    //     // If a valid session is active, forward them seamlessly straight to the home dashboard
    //     Get.offAllNamed(RouteHelper.getInitial()); 
    //   }
    // });
    Timer(const Duration(seconds: 3), () {
        print("DEBUG: Splash animation finished. Handing routing control to AuthService.");
    });

    super.initState();
    
    () async {
      await listExample();
      putPdfNameInItem();
    }();
  }

  // To prevent memory leak exceptions when navigating out of the splash layout
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          ScaleTransition(
            scale: animation,
            child: Center(
              child: Image.asset(
                'assets/images/spalsh_screen_1.png',
                width: Dimensions.splashImg,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/spalsh_screen_2.png',
              width: Dimensions.splashImg, 
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
