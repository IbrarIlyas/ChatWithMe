import 'dart:io';

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

  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((user) async {
      if (user.exists) {
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('Id', isNotEqualTo: currentUser.uid)
        .orderBy('Id')
        .snapshots();
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    return firestore.collection('messages').snapshots();
  }
}
