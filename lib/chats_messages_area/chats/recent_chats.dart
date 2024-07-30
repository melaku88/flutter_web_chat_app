import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class RecentChats extends StatefulWidget {
  const RecentChats({super.key});

  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  // ==================================================================================================
  late UserModel fromUserData;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription streamSubscriptionChats;

  getRecentChats(){
    final streamRecentChats = FirebaseFirestore.instance
      .collection('RecentChats')
      .doc(fromUserData.uid)
      .collection('lastMessage')
      .snapshots();

      streamSubscriptionChats = streamRecentChats.listen((newMessage) { 
        streamController.add(newMessage);
      });
  }

  getLoggedUserData(){
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      setState(() {
        fromUserData = UserModel(
          currentUser.uid, 
          currentUser.displayName ?? '', 
          currentUser.email ?? '', 
          '', 
          currentUser.photoURL ?? ''
        );
      });
    }
    getRecentChats();
  }

  @override
  void initState() {
    super.initState();
    getLoggedUserData();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionChats.cancel();
  }
  // ==================================================================================================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamController.stream, 
      builder: (context, snapshots){
        switch(snapshots.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('loading recent chats'),
                SizedBox(height: 10.0,),
                CircularProgressIndicator(color: DefaultColors.primary,)
              ],
            ),
          );
          case ConnectionState.active:
          case ConnectionState.done:
          if(snapshots.hasError){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error occurred!', style: TextStyle(color: Colors.red),),
                ],
              ),
            );
          }else{
            final snapshotDatas = snapshots.data as QuerySnapshot;
            List<DocumentSnapshot> recentChatLists = snapshotDatas.docs.toList();

            if(recentChatLists.isEmpty){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No any chat yet!'),
                  ],
                ),
              );
            }else{
              return ListView.separated(
                itemCount: recentChatLists.length, 
                separatorBuilder: (context, index){
                  return Divider(
                    color: Colors.grey.shade300, thickness: 0.3,
                  );
                }, 
                itemBuilder: (context, index){
                  DocumentSnapshot recentData = recentChatLists[index];
                  String lastMessage = recentData['lastMessage'];
                  final toUserData = UserModel(
                    recentData['toUserId'], 
                    recentData['toName'], 
                    recentData['toEmail'], 
                    '', 
                    recentData['toProfilePic'],
                  );

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/messages', arguments: toUserData);
                    },
                    leading: CircleAvatar(
                      radius: 26.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(toUserData.profilePic),
                    ),
                    title: Text(toUserData.name),
                    subtitle: Text(lastMessage.toString().contains('.jpg') ? 
                      'Image....' : lastMessage.toString().contains('.pdf')
                      || lastMessage.toString().contains('.mp4') || lastMessage.toString().contains('.mp3') || lastMessage.toString().contains('.docx') || lastMessage.toString().contains('.pptx') || lastMessage.toString().contains('.xlsx') ? 'File....' 
                      : lastMessage.toString(), style: TextStyle(
                        color: Colors.grey, fontSize: 13.0
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: EdgeInsets.all(8.0),
                  );
                }
              );
            }
          }
        }
      }
    );
  }
}