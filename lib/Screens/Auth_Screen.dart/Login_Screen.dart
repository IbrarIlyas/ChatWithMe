import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Helpers/Dialog.dart';
import 'package:chatwm/Screens/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Api/Api.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  Size mq = const Size(0, 0);
  static final RxBool isanimate = false.obs;
  LoginScreen({super.key});

  void _init(BuildContext context) {
    mq = MediaQuery.of(context).size;
    Future.delayed(const Duration(milliseconds: 500), () {
      isanimate.value = true;
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
      appBar: AppBar(
        elevation: 10,
        automaticallyImplyLeading: false,
        title: const Text(
          "Chat with me",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  purple1,
                  purple2,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Obx(
            () => AnimatedPositioned(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(milliseconds: 1200),
              height: mq.height * 0.5,
              width: mq.width * .75,
              left: isanimate.value ? mq.width * 0.125 : -mq.width * 0.125,
              top: mq.height * 0.1,
              child: Image.asset(
                "assets/Images/icon.png",
                color: whitecolor,
              ),
            ),
          ),
          Obx(
            () => AnimatedPositioned(
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 700),
              height: 50,
              left: mq.width * 0.1,
              right: mq.width * 0.1,
              bottom: isanimate.value ? mq.height * 0.16 : 0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: blackcolor),
                  backgroundColor: whitecolor,
                ),
                label: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "SignIn with",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: blackcolor,
                        ),
                      ),
                      TextSpan(
                        text: " Google",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: blackcolor),
                      )
                    ],
                  ),
                ),
                onPressed: () {
                  _SigninwithGoogleHandler(context);
                },
                icon: Image.asset(
                  "assets/Images/google.png",
                  height: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _SigninwithGoogleHandler(BuildContext context) {
    Dialogs.showprogressbar(context);
    _signInWithGoogle().then((value) async {
      if (value.user != null) {
        print("User Credential :  ${value.credential}");
        print("User additional information :  ${value.additionalUserInfo}");
        if (await Api.UserExist()) {
          Get.offAll(() => const Homescreen());
        } else {
          await Api.CreateUser().then((value) {
            navigator!.pop(context);
            Get.offAll(() => const Homescreen());
          });
        }
        Get.snackbar(
            'Success', 'Signed in successfully ${Api.currentUser.email} !');
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.offAll(() => const Homescreen());
        });
      }
    }).catchError((error) {
      print(error);
      Get.snackbar('Error', 'Failed to sign in: $error');
    });
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await Api.auth.signInWithCredential(credential);
  }
}
