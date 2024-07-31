import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Helpers/DateTimeUtils.dart';
import 'package:chatwm/Screens/userProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Api/Api.dart';
import '../Helpers/MessageBuble.dart';
import '../Models/Message.dart';
import '../Models/User.dart';

class ChattingSCreen extends StatefulWidget {
  ChatUser _user;
  ChattingSCreen(this._user, {super.key});

  @override
  State<ChattingSCreen> createState() => _ChattingSCreenState();
}

class _ChattingSCreenState extends State<ChattingSCreen> {
  bool isEmojiShown = false;
  RxBool isSendingImage = false.obs;
  ImagePicker picker = ImagePicker();
  List<Message> messageList = [];
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isEmojiShown,
      onPopInvoked: (didPop) {
        if (isEmojiShown) {
          setState(() {
            isEmojiShown = !isEmojiShown;
          });
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [purple2, purple1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
            ),
            Scaffold(
              appBar: AppBar(
                elevation: 10,
                shadowColor: Colors.black,
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                flexibleSpace: InkWell(
                    onTap: () {
                      Get.to(userProfileScreen(
                        user: widget._user,
                      ));
                    },
                    child: _appBar()),
                backgroundColor: purple2,
              ),
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: Api.getAllMessages(widget._user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: SizedBox(),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (snapshot.hasData) {
                              messageList = snapshot.data!.docs
                                  .map((doc) => Message.fromJson(doc.data()))
                                  .toList();
                            }
                            if (messageList.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                itemCount: messageList.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageBubble(
                                      message: messageList[index]);
                                },
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  "Say hi 👋",
                                  style: TextStyle(
                                      color: whitecolor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => isSendingImage.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CircularProgressIndicator(
                                color: whitecolor,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 4,
                          ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 10,
                          shadowColor: purple1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      FocusScope.of(context).unfocus();
                                      isEmojiShown = !isEmojiShown;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.emoji_emotions_sharp,
                                    color: purple1,
                                  )),
                              Expanded(
                                  child: TextField(
                                onTap: () {
                                  if (isEmojiShown == true) {
                                    setState(() {
                                      isEmojiShown = !isEmojiShown;
                                    });
                                  }
                                },
                                controller: messageController,
                                cursorColor: purple1,
                                style: const TextStyle(
                                    color: purple1,
                                    fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Message",
                                    hintStyle: TextStyle(
                                        color: purple1,
                                        fontWeight: FontWeight.w400)),
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                minLines: 1,
                              )),
                              IconButton(
                                  onPressed: () async {
                                    final List<XFile> images =
                                        await picker.pickMultiImage(
                                      imageQuality: 40,
                                    );
                                    for (var image in images) {
                                      isSendingImage.value = true;
                                      await Api.sendImage(
                                          widget._user, File(image.path));
                                      isSendingImage.value = false;
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.photo,
                                    color: purple1,
                                  )),
                              IconButton(
                                onPressed: () async {
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 40,
                                  );
                                  isSendingImage.value = true;
                                  await Api.sendImage(
                                      widget._user, File(image!.path));
                                  isSendingImage.value = false;
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: purple1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: whitecolor,
                        child: IconButton(
                          padding: const EdgeInsets.only(left: 5),
                          onPressed: () async {
                            if (messageController.text.isNotEmpty) {
                              try {
                                if (messageList.isEmpty) {
                                  await Api.sendFirstMessage(
                                    widget._user,
                                    messageController.text,
                                    Type.text,
                                  );
                                } else {
                                  await Api.sendMessage(
                                    widget._user,
                                    messageController.text,
                                    Type.text,
                                  );
                                }
                                messageController.clear();
                              } catch (e) {
                                print('Error sending message: $e');
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: purple1,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                    ],
                  ),
                  if (isEmojiShown)
                    EmojiPicker(
                      textEditingController: messageController,
                      config: const Config(
                        height: 260,
                        emojiViewConfig: EmojiViewConfig(emojiSizeMax: 24),
                        categoryViewConfig: CategoryViewConfig(
                          backgroundColor: Color.fromARGB(255, 201, 77, 190),
                          iconColor: whitecolor,
                          iconColorSelected: purple1,
                          indicatorColor: purple1,
                        ),
                        bottomActionBarConfig: BottomActionBarConfig(
                          backgroundColor: Color.fromARGB(255, 201, 77, 190),
                          buttonColor: Color.fromARGB(255, 201, 77, 190),
                        ),
                        searchViewConfig: SearchViewConfig(
                          backgroundColor: whitecolor,
                          buttonColor: Colors.black12,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Api.getUserInfo(widget._user),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List<dynamic> list = [];
        if (snapshot.hasData) {
          list = snapshot.data!.docs
              .map((doc) =>
                  ChatUser.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        }
        return Row(
          children: [
            IconButton(
              onPressed: () {
                navigator?.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: whitecolor,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(
                height: 45,
                width: 45,
                imageUrl: list.isNotEmpty ? list[0].Image : widget._user.Image,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  return const CircleAvatar(
                    child: Icon(Icons.person_2_outlined),
                  );
                },
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].Name : widget._user.Name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: whitecolor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    list.isNotEmpty
                        ? list[0].IsOnline
                            ? "Online"
                            : DateTimeUtils.getLastActiveTime(
                                context: context, sendTime: list[0].LastActive)
                        : DateTimeUtils.getLastActiveTime(
                            context: context,
                            sendTime: widget._user.LastActive),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: whitecolor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 17,
            )
          ],
        );
      },
    );
  }
}
