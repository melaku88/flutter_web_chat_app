import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';
import 'package:flutter_web_chat_app/widgets/messag_widget.dart';

class MessagePage extends StatefulWidget {
  final UserModel toUserData;
  const MessagePage(
     this.toUserData,
    {Key? key}
  ) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // ========================================================================================
  late UserModel toUser;
  late UserModel fromUser;

  getUserData()async{
    User? loggedInUser = await FirebaseAuth.instance.currentUser;
    
    if(loggedInUser != null){
      setState(() {
        fromUser = UserModel(
          loggedInUser.uid, 
          loggedInUser.displayName ?? '', 
          loggedInUser.email ?? '', 
          '' , 
          loggedInUser.photoURL ?? ''
        );
      });
    }
    setState(() {
      toUser = widget.toUserData;
    });
  }
  @override
  void initState() {
    super.initState();
    getUserData();
  }
  // =========================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DefaultColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 23.0,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(toUser.profilePic.toString()),
            ),
            SizedBox(width: 8.0,),
            Text(toUser.name.toString(), style: TextStyle(fontSize: 16.0),)
          ],
        ),
        actions: [Icon(Icons.more_vert)],
      ),
      body: SafeArea(
        child: MessagesWidget(toUserData: toUser, fromUserData: fromUser)
      ),
    );
  }
}
