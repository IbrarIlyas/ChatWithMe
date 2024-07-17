import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Models/User.dart';
import 'package:chatwm/Screens/Auth_Screen.dart/Login_Screen.dart';
import 'package:flutter/material.dart';
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
                          child: ClipOval(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: whitecolor,
                              child: const Icon(
                                Icons.edit,
                                color: purple2,
                              ),
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
                Dialogs.showprogressbar(context);
                await Api.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Get.offAll(LoginScreen());
                  });
                });
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
