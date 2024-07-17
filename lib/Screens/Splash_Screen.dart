import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Screens/Auth_Screen.dart/Login_Screen.dart';
import 'package:chatwm/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../Api/Api.dart';

// ignore: must_be_immutable
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Size mq = const Size(0, 0);

  void _init(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //seting the color of status bar transparnet
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    mq = MediaQuery.of(context).size;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Api.auth.currentUser != null) {
        Get.offAll(() => const Homescreen());
      } else {
        Get.offAll(() => LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensuring _init is called before the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init(context);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WidgetAnimator(
              incomingEffect: WidgetTransitionEffects.incomingScaleDown(),
              atRestEffect: WidgetRestingEffects.bounce(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Image.asset(
                  height: 300,
                  width: 300,
                  "assets/Images/icon.png",
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const TextAnimator(
              "Chat with ME!",
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: purple2, fontSize: 25, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
