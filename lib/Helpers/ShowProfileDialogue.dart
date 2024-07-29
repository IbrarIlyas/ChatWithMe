import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatwm/Constant/constant.dart';
import 'package:chatwm/Models/User.dart';
import 'package:chatwm/Screens/userProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class showProfileDialogue extends StatefulWidget {
  final ChatUser user;
  const showProfileDialogue({required this.user, super.key});

  @override
  State<showProfileDialogue> createState() => _showProfileDialogueState();
}

class _showProfileDialogueState extends State<showProfileDialogue> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.user.Name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(userProfileScreen(user: widget.user));
                  },
                  icon: const Icon(Icons.info_outline, color: purple1))
            ],
          ),
          const Divider(
            color: purple1,
            thickness: 1,
          ),
        ],
      ),
      content: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: widget.user.Image,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 100,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
