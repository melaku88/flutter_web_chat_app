import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String uid;
  String message;
  Timestamp dateTime;

  MessageModel(
    this.uid,
    this.message,
    this.dateTime
  );

  Map<String, dynamic> toJson(){
    return{
      'uid': uid,
      'message': message,
      'date': dateTime
    };
  }
}