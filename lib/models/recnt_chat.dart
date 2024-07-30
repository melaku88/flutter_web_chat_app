class RecentChatModel{
  String fromUserId;
  String toUserId;
  String toName;
  String toEmail;
  String toProfilePic;
  String lastMessage;

  RecentChatModel(
    this.fromUserId,
    this.toUserId,
    this.toName,
    this.toEmail,
    this.toProfilePic,
    this.lastMessage
  );
    Map<String, dynamic> toJson(){
     return{
      'fromUserId': fromUserId,
      'toUserId':  toUserId,
      'toName': toName,
      'toEmail': toEmail,
      'toProfilePic': toProfilePic,
      'lastMessage': lastMessage
    };
  }

}