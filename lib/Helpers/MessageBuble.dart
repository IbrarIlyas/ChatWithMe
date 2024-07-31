import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Api/Api.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Helpers/DateTimeUtils.dart';
import 'package:chatwm/Models/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final myMsgColor = const Color.fromRGBO(225, 0, 255, 0.401);

  final otherMsgColor = const Color.fromRGBO(127, 0, 255, 0.401);
  @override
  Widget build(BuildContext context) {
    bool isMe = widget.message.fromId == Api.currentUser.uid;
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            backgroundColor: whitecolor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            builder: (_) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    height: 3,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: purple1,
                    ),
                  ),
                  widget.message.type == Type.text
                      ? _OptionButton(
                          icon: Icon(
                            Icons.copy,
                            color: Colors.blue,
                          ),
                          label: "Copy",
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(
                                text: widget.message.messageText));
                            navigator!.pop(context);
                          })
                      : _OptionButton(
                          icon: Icon(
                            Icons.download,
                            color: Colors.blue,
                          ),
                          label: "Download ",
                          onTap: () async {
                            try {
                              final success = await GallerySaver.saveImage(
                                  widget.message.messageText,
                                  albumName: 'Chat With Me');
                              if (success != null && success) {
                                Navigator.pop(context);
                              } else {
                                print('Failed to save image');
                              }
                            } catch (e) {
                              print('Error saving image: $e');
                            }
                          }),
                  Divider(
                    color: Colors.black26,
                    indent: 20,
                    endIndent: 20,
                  ),
                  if (widget.message.fromId == Api.currentUser.uid)
                    if (widget.message.type == Type.text)
                      _OptionButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        label: "Edit",
                        onTap: () {
                          Navigator.pop(context);
                          showEditMessage(context, widget.message.messageText,
                              widget.message);
                        },
                      ),
                  if (widget.message.fromId == Api.currentUser.uid)
                    _OptionButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        label: "Delete Message",
                        onTap: () {
                          Api.deleteMessage(widget.message);
                          Navigator.pop(context);
                        }),
                  if (widget.message.fromId == Api.currentUser.uid)
                    Divider(
                      color: Colors.black26,
                      indent: 20,
                      endIndent: 20,
                    ),
                  _OptionButton(
                      icon: Icon(Icons.remove_red_eye_outlined,
                          color: Colors.blue),
                      label:
                          "Sent at : ${DateTimeUtils.convertDate(context: context, time: widget.message.sendAt)}",
                      onTap: () {}),
                  _OptionButton(
                      icon: Icon(Icons.remove_red_eye, color: Colors.green),
                      label: widget.message.readAt.isEmpty
                          ? "Read at : Not seen yet"
                          : "Read at : ${DateTimeUtils.readMessageDate(context: context, sendTime: widget.message.readAt)}",
                      onTap: () {}),
                ],
              );
            });
      },
      child: isMe ? myMessage() : otherMessage(),
    );
  }

  Widget myMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            DateTimeUtils.convertDate(
                context: context, time: widget.message.sendAt),
            style: const TextStyle(
                color: whitecolor, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(
                  top: 10, right: 10, left: 10, bottom: 3),
              decoration: BoxDecoration(
                color: myMsgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                border: Border.all(color: whitecolor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.message.type == Type.text
                      ? Text(
                          widget.message.messageText,
                          style: const TextStyle(
                            color: whitecolor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.messageText,
                            placeholder: (context, url) => const Icon(
                              Icons.image,
                              size: 100,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                  Icon(
                    Icons.done_all_sharp,
                    color: widget.message.readAt.isNotEmpty
                        ? const Color.fromARGB(255, 0, 106, 255)
                        : whitecolor,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget otherMessage() {
    if (widget.message.readAt.isEmpty) {
      Api.updateReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(
                  top: 10, left: 10, right: 10, bottom: 3),
              decoration: BoxDecoration(
                color: otherMsgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: whitecolor, width: 2),
              ),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.messageText,
                      style: const TextStyle(
                        color: whitecolor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.messageText,
                        placeholder: (context, url) => const Icon(
                          Icons.image,
                          size: 100,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            DateTimeUtils.convertDate(
                context: context, time: widget.message.sendAt),
            style: const TextStyle(
                color: whitecolor, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

void showEditMessage(BuildContext context, String msg, Message message) {
  TextEditingController editingController = TextEditingController(text: msg);
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blue,
            ),
            Text(
              "  Edit Message",
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
          controller: editingController,
          decoration: InputDecoration(
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
              await Api.updateMessage(
                  msg: message, updatedMsg: editingController.text);
              Navigator.pop(context);
            },
            child: Text(
              'Edit',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}

class _OptionButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback onTap;
  const _OptionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: icon,
        title: Text(label),
        onTap: () => onTap(),
      ),
    );
  }
}
