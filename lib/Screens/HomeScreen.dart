import 'package:chatwm/Api/Api.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Models/User.dart';
import 'package:chatwm/Screens/Profile_Screen.dart';
import 'package:chatwm/Widget/ChatUserCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<ChatUser> chatUsers = [];
  List<ChatUser> searched_User = [];

  RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await Api.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: !isSearching.value,
        onPopInvoked: (value) {
          if (isSearching.value) {
            isSearching.value = false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (chatUsers.isNotEmpty) {
                  Get.to(ProfilePage(user: Api.me));
                }
              },
            ),
            actions: [
              Obx(
                () => IconButton(
                    onPressed: () {
                      isSearching.value = !isSearching.value;
                    },
                    icon: isSearching.value
                        ? const Icon(Icons.cancel)
                        : const Icon(Icons.search)),
              )
            ],
            automaticallyImplyLeading: false,
            backgroundColor: purple2,
            title: Obx(
              () => isSearching.value
                  ? TextField(
                      decoration: const InputDecoration(
                        fillColor: whitecolor,
                        filled: true,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                      autofocus: true,
                      onChanged: (value) {
                        searched_User.clear();
                        for (ChatUser user in chatUsers) {
                          if (user.Name.toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              user.Email.toLowerCase()
                                  .contains(value.toLowerCase())) {
                            searched_User.add(user);
                          }
                        }
                        setState(() {});
                      },
                    )
                  : const Text("Chat with me"),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: purple2,
            child: const Icon(
              Icons.message,
              color: whitecolor,
            ),
            onPressed: () async {
              await Api.auth.signOut();
              await GoogleSignIn().signOut();
            },
          ),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.purple.shade300,
                  Colors.purpleAccent.shade100,
                ],
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: Api.getAllUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      chatUsers = snapshot.data!.docs
                          .map((doc) => ChatUser.fromJson(
                              doc.data() as Map<String, dynamic>))
                          .toList();
                    }
                    return Obx(
                      () => ListView.builder(
                        itemCount: isSearching.value
                            ? searched_User.length
                            : chatUsers.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                              user: isSearching.value
                                  ? searched_User[index]
                                  : chatUsers[index]);
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
