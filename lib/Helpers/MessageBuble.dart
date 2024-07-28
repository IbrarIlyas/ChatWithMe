import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Api/Api.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Helpers/DateTimeUtils.dart';
import 'package:chatwm/Models/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    return widget.message.fromId == Api.currentUser.uid
        ? myMessage()
        : otherMessage();
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
                color: myMsgColor,
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
