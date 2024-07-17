class ChatUser {
  ChatUser({
    required this.IsOnline,
    required this.Email,
    required this.Id,
    required this.Image,
    required this.LastActive,
    required this.PushToken,
    required this.CreatedAt,
    required this.About,
    required this.Name,
  });
  late bool IsOnline;
  late String Email;
  late String Id;
  late String Image;
  late String LastActive;
  late String PushToken;
  late String CreatedAt;
  late String About;
  late String Name;

  ChatUser.fromJson(Map<String, dynamic> json) {
    IsOnline = json['Is_Online'] ?? "";
    Email = json['Email'] ?? "";
    Id = json['Id'] ?? "";
    Image = json['Image'] ?? "";
    LastActive = json['Last_Active'] ?? "";
    PushToken = json['Push_Token'] ?? "";
    CreatedAt = json['Created_at'] ?? "";
    About = json['About'] ?? "";
    Name = json['Name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Is_Online'] = IsOnline;
    data['Email'] = Email;
    data['Id'] = Id;
    data['Image'] = Image;
    data['Last_Active'] = LastActive;
    data['Push_Token'] = PushToken;
    data['Created_at'] = CreatedAt;
    data['About'] = About;
    data['Name'] = Name;
    return data;
  }
}
