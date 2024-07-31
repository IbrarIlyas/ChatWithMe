import 'dart:developer';
import 'package:chatwm/Api/Api.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Models/User.dart';
import 'package:chatwm/Screens/Profile_Screen.dart';
import 'package:chatwm/Widget/ChatUserCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Api.auth.currentUser != null) {
        if (message.toString().contains('paused')) {
          Api.updateActiveStatus(isOnline: false);
        }
        if (message.toString().contains('resumed')) {
          Api.updateActiveStatus(isOnline: true);
        }
      }
      return Future.value(message);
    });
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await Api.getSelfInfo().then((onValue) {
      log("Successfully updated me");
    });
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
                      : const Icon(Icons.search),
                ),
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
            onPressed: () {
              showAddPersonDialog(context);
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
            child: StreamBuilder(
              stream: Api.getMyUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: SizedBox(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder<QuerySnapshot>(
                      stream: Api.getAllUser(
                          snapshot.data?.docs.map((e) => (e.id)).toList() ??
                              []),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(
                              child: Text(
                                "Say hi to Someone 👋",
                                style:
                                    TextStyle(color: whitecolor, fontSize: 20),
                              ),
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

void showAddPersonDialog(BuildContext context) {
  TextEditingController emailController = TextEditingController();
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.blue,
            ),
            Text(
              "  Email",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            )
          ],
        ),
        contentPadding:
            EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
        content: TextField(
          cursorColor: purple1,
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIconColor: Colors.blue,
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty &&
                  emailController.text != Api.currentUser.email) {
                await Api.addChatUser(emailController.text);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Add',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
