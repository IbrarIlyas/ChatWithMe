import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Api/Api.dart';
import 'package:chatwm/Helpers/DateTimeUtils.dart';
import 'package:chatwm/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/Message.dart';
import '../Screens/Chat_Screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Get.to(ChattingSCreen(widget.user));
        },
        child: StreamBuilder(
          stream: Api.getLastMessages(widget.user),
          builder: (context, snapshot) {
            List<Message> tempList;
            if (snapshot.hasData) {
              tempList = snapshot.data!.docs
                  .map((doc) => Message.fromJson(doc.data()))
                  .toList();

              if (tempList.isNotEmpty) {
                _message = tempList[0];
              }
            }
            return ListTile(
              title: Text(
                widget.user.Name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: _message != null
                  ? _message!.type == Type.image
                      ? const Text(
                          "Image",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          _message!.messageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                  : Text(
                      widget.user.About,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  imageUrl: widget.user.Image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    return const CircleAvatar(
                      child: Icon(Icons.person_2_outlined),
                    );
                  },
                ),
              ),
              trailing: _message == null
                  ? null
                  : (_message!.readAt.isEmpty)
                      ? const Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 12,
                        )
                      : Text(
                          DateTimeUtils.getLastmessageFormat(
                              context: context, sendTime: _message!.readAt),
                          maxLines: 1,
                        ),
            );
          },
        ),
      ),
    );
  }
}
