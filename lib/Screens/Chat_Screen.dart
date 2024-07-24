import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Api/Api.dart';
import '../Models/User.dart';

class ChattingSCreen extends StatefulWidget {
  final ChatUser _user;
  const ChattingSCreen(this._user, {super.key});

  @override
  State<ChattingSCreen> createState() => _ChattingSCreenState();
}

class _ChattingSCreenState extends State<ChattingSCreen> {
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
                    stream: Api.getAllMessages(),
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
                            final data = snapshot.data!.docs;
                            print(jsonEncode(data[0].data()));
                          }
                          return ListView.builder(
                            itemCount: 10,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Placeholder();
                            },
                          );
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
                            const Expanded(
                                child: TextField(
                              showCursor: false,
                              style: TextStyle(
                                  color: purple1, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "   Message  ",
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
                        onPressed: () {},
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
