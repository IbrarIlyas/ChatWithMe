class Message {
  Message({
    required this.toId,
    required this.type,
    required this.readAt,
    required this.messageText,
    required this.fromId,
    required this.sendAt,
  });

  late String toId;
  late Type type;
  late String readAt;
  late String messageText;
  late String fromId;
  late String sendAt;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['ToId'].toString();
    type = json['Type'] == 'image' ? Type.image : Type.text;
    readAt = json['ReadAt'].toString();
    messageText = json['Message'].toString();
    fromId = json['FromId'].toString();
    sendAt = json['SendAt'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ToId'] = toId;
    data['Type'] = type.name;
    data['ReadAt'] = readAt;
    data['Message'] = messageText;
    data['FromId'] = fromId;
    data['SendAt'] = sendAt;
    return data;
  }
}

enum Type { image, text }
