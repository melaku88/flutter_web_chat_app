import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';
import 'package:flutter_web_chat_app/provider/provider_chat.dart';
import 'package:flutter_web_chat_app/widgets/messag_widget.dart';
import 'package:provider/provider.dart';

class MessageArea extends StatefulWidget {
  final UserModel currentUserData;
 const MessageArea({super.key, required this.currentUserData});

  @override
  State<MessageArea> createState() => _MessageAreaState();
}

class _MessageAreaState extends State<MessageArea> {
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    screenWidth= MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    UserModel? toUserData = context.watch<ProviderChat>().toUserData;

    return toUserData == null ? Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Select a chat/contact', style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),),
              Text('TO', style: TextStyle(color: Colors.grey.shade300, fontSize: 45.0),),
              Text('start messaging', style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),)
            ],
          ),
        ),
      ) : Column(
        children: [
          // header
          Container(
            color: DefaultColors.barBackground,
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(toUserData.profilePic.toString()),
                ),
                SizedBox(width: 10.0,),
                Text(toUserData.name.toString()),

                Spacer(),

                Icon(Icons.search),
                Icon(Icons.more_vert)
              ],
            ),
          ),

          // message List
          Expanded(
            child: MessagesWidget(
              toUserData: toUserData, 
              fromUserData: widget.currentUserData
            )
          )
        ],
      );
  }
}