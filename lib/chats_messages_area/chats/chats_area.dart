import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_chat_app/chats_messages_area/chats/contacts_list.dart';
import 'package:flutter_web_chat_app/chats_messages_area/chats/recent_chats.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class ChatArea extends StatelessWidget {
  final UserModel currentUserData;
  const ChatArea({super.key, required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: DefaultColors.lightBarBackground,
          border: Border(
            right: BorderSide(width: 1, color: DefaultColors.barBackground),
          )
        ),
        child: Column(
          children: [
            Container(
              color: DefaultColors.background,
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(currentUserData.profilePic.toString()),
                  ),
                  SizedBox(width: 12.0,),
                  Text(
                    currentUserData.name.toString(),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async{
                      await FirebaseAuth.instance.signOut().then((value){
                        Navigator.pushReplacementNamed(context, '/login');
                      });
                    },
                    child: Icon(Icons.logout)
                  )
                ],
              ),
            ),
            TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: DefaultColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 14.0),
              tabs: [
                Tab(
                  text: 'Chats',
                ),
                Tab(
                  text: 'Contacts',
                )
              ]
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: RecentChats(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ContactsList(),
                    ),
                  ]
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}