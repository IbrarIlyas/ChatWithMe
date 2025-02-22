import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatwm/Models/Message.dart';
import 'package:chatwm/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage firebasestorage = FirebaseStorage.instance;

  static User currentUser = auth.currentUser!;

  static late ChatUser me;

  // static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // static Future<void> getFirebaseToken() async {
  //   await firebaseMessaging.requestPermission();

  //   await firebaseMessaging.getToken().then((_) {
  //     if (_ != null) {
  //       me.PushToken = _;
  //       print("Token is : $_");
  //     }
  //     print("Token is empty ");
  //   });
  // }

  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        log(jsonEncode(user.data()));
        me = ChatUser.fromJson(user.data()!);
      } else {
        await CreateUser().then((user) => getSelfInfo());
      }
    });
  }

  static Future<bool> UserExist() async {
    return (await firestore.collection('users').doc(currentUser.uid).get())
        .exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('Email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != currentUser.uid) {
      //user exists
      firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesn't exists
      return false;
    }
  }

  static Future<void> UpdateUser() async {
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .update({'Name': me.Name, 'About': me.About});
  }

  static Future<void> CreateUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final ChatUser User = ChatUser(
      Name: currentUser.displayName.toString(),
      Email: currentUser.email!,
      About: "Hey! I am using Chat with Me",
      Id: currentUser.uid,
      Image: currentUser.photoURL!,
      IsOnline: false,
      LastActive: time.toString(),
      CreatedAt: time.toString(),
      PushToken: '',
    );
    await firestore.collection('users').doc(User.Id).set(User.toJson());
  }

  static getAllUser(List<String> userIdList) {
    if (userIdList.isEmpty) {
      return null;
    } else {
      return firestore
          .collection('users')
          .where('Id', whereIn: userIdList)
          .orderBy('Id')
          .snapshots();
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsers() {
    return firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.Id)
        .collection('my_users')
        .doc(currentUser.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;

    final ref = await firebasestorage.ref('ProfilePic/${currentUser.uid}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((onValue) {
      print('bYte uploaded : ${onValue.bytesTransferred / 1000}');
    });

    me.Image = await ref.getDownloadURL();

    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .update({'Image': me.Image});
  }

  static String getConversationID(String id) {
    if (id.hashCode <= currentUser.uid.hashCode) {
      return '${currentUser.uid}_$id';
    } else {
      return '${id}_${currentUser.uid}';
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.Id)}/messages/')
        .orderBy('SendAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser user) {
    return firestore
        .collection('users')
        .where('Id', isEqualTo: user.Id)
        .snapshots();
  }

  static Future<void> updateReadStatus(Message msg) async {
    firestore
        .collection('chats/${getConversationID(msg.fromId)}/messages/')
        .doc(msg.sendAt)
        .update({'ReadAt': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.Id)}/messages/')
        .orderBy('SendAt', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser otheruser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    Message message = Message(
        toId: otheruser.Id,
        type: type,
        readAt: '',
        messageText: msg,
        fromId: Api.currentUser.uid,
        sendAt: time);

    final ref = firestore
        .collection('chats/${getConversationID(otheruser.Id)}/messages/');
    try {
      await ref.doc(time).set(message.toJson());
    } catch (e) {
      print("This is the error : $e");
    }
  }

  static Future<void> sendImage(ChatUser otherUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = await firebasestorage.ref(
        'Images/${getConversationID(otherUser.Id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((onValue) {
      print('Image send -> uploaded : ${onValue.bytesTransferred / 1000}');
    });

    String imageUrl = await ref.getDownloadURL();

    await sendMessage(otherUser, imageUrl, Type.image);
  }

  static Future<void> updateActiveStatus({required bool isOnline}) async {
    firestore.collection('users').doc(currentUser.uid).update({
      'Is_Online': isOnline,
      'Last_Active': DateTime.now().millisecondsSinceEpoch.toString(),
      'Push_Token': me.PushToken
    });
  }

  static Future<void> updateMessage(
      {required Message msg, required String updatedMsg}) async {
    try {
      await firestore
          .collection('chats/${getConversationID(msg.toId)}/messages/')
          .doc(msg.sendAt)
          .update({'Message': updatedMsg});
    } catch (e) {
      log("Here is the error : $e");
    }
  }

  static Future<void> deleteMessage(Message msg) async {
    await firestore
        .collection('chats/${getConversationID(msg.toId)}/messages/')
        .doc(msg.sendAt)
        .delete();

    if (msg.type == Type.image) {
      await firebasestorage.refFromURL(msg.messageText).delete();
    }
  }
}
