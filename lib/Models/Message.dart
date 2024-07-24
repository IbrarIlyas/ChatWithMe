class AutoGenerate {
  AutoGenerate({
    required this.ToId,
    required this.Type,
    required this.ReadAt,
    required this.Message,
    required this.FromId,
    required this.SendAt,
  });
  late String ToId;
  late String Type;
  late String ReadAt;
  late String Message;
  late String FromId;
  late String SendAt;

  AutoGenerate.fromJson(Map<String, dynamic> json) {
    ToId = json['ToId'];
    Type = json['Type'];
    ReadAt = json['ReadAt'];
    Message = json['Message'];
    FromId = json['FromId'];
    SendAt = json['SendAt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ToId'] = ToId;
    data['Type'] = Type;
    data['ReadAt'] = ReadAt;
    data['Message'] = Message;
    data['FromId'] = FromId;
    data['SendAt'] = SendAt;
    return data;
  }
}
