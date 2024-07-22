import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Models/User.dart';
import 'package:chatwm/Screens/Auth_Screen.dart/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Api/Api.dart';
import '../Helpers/Dialog.dart';

class ProfilePage extends StatelessWidget {
  final ChatUser user;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _about = TextEditingController();
  late final String _image;

  ProfilePage({Key? key, required this.user}) {
    _name.text = user.Name;
    _about.text = user.About;
    _email.text = user.Email;
    _image = user.Image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: purple2,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: CachedNetworkImageProvider(
                            _image,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: whitecolor,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: IconButton(
                              onPressed: () {
                                ShowBottomSheet(context);
                              },
                              icon: const Icon(Icons.edit),
                              color: purple2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _email.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _about,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'About',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_name.text.isNotEmpty && _about.text.isNotEmpty) {
                          Api.me.Name = _name.text;
                          Api.me.About = _about.text;
                          Api.UpdateUser();
                          Get.snackbar('Updated',
                              "Successfully updated the user information");
                        } else {
                          Get.snackbar(
                              'Invalid Input', "Text fields cannot be empty!");
                        }
                      },
                      icon: const Icon(
                        Icons.login_outlined,
                        color: whitecolor,
                      ),
                      label: const Text(
                        'Update',
                        style: TextStyle(color: whitecolor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  Dialogs.showprogressbar(context);

                  await GoogleSignIn().signOut();

                  await Api.auth.signOut();

                  await GoogleSignIn().disconnect();

                  Navigator.of(context).pop();
                  Get.offAll(() => LoginScreen());
                } catch (e) {
                  Navigator.of(context).pop();
                  Get.snackbar('Error', 'Failed to log out: $e');
                }
              },
              icon: const Icon(
                Icons.logout_outlined,
                color: whitecolor,
              ),
              label: const Text(
                "LogOut",
                style: TextStyle(color: whitecolor),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                backgroundColor: Colors.red.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void ShowBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      backgroundColor: whitecolor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        fixedSize: const Size(100, 100),
                        backgroundColor: whitecolor,
                        alignment: Alignment.center),
                    onPressed: () {},
                    child: Image.asset(
                      'assets/Images/picture.png',
                    )),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        fixedSize: const Size(100, 100),
                        backgroundColor: whitecolor,
                        alignment: Alignment.center),
                    onPressed: () {},
                    child: Image.asset(
                      'assets/Images/camera.png',
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      });
}
