import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:flutter/material.dart';
import '../Api/Api.dart';
import '../Helpers/MessageBuble.dart';
import '../Models/Message.dart';
import '../Models/User.dart';

class ChattingSCreen extends StatefulWidget {
  final ChatUser _user;
  const ChattingSCreen(this._user, {super.key});

  @override
  State<ChattingSCreen> createState() => _ChattingSCreenState();
}

class _ChattingSCreenState extends State<ChattingSCreen> {
  List<Message> messageList = [];
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              flexibleSpace: _appBar(),
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
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.emoji_emotions_sharp,
                                  color: purple1,
                                )),
                            Expanded(
                                child: TextField(
                              controller: messageController,
                              cursorColor: purple1,
                              style: const TextStyle(
                                  color: purple1, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Message  ",
                                  hintStyle: TextStyle(
                                      color: purple1,
                                      fontWeight: FontWeight.w400)),
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                            )),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.photo,
                                  color: purple1,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: purple1,
                                ))
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
                              await Api.sendMessage(
                                  widget._user, messageController.text);
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
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
            imageUrl: widget._user.Image,
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
                widget._user.Name,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: whitecolor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                "Last since 15 min",
                style: TextStyle(
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
  }
}
