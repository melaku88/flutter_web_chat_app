import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/chats_messages_area/chats/chats_area.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //=========================================================================
  double screenWidth = 0;
  double screenHeight = 0;

  late UserModel currentUserData;

  readCurrentUserData()async{
    User? currentUser = FirebaseAuth.instance.currentUser;

    if(currentUser != null){
      String uid = currentUser.uid;
      String name = currentUser.displayName ?? '';
      String email = currentUser.email ?? '';
      String password = '';
      String photo = currentUser.photoURL ?? '';

      setState(() {
        currentUserData = UserModel(uid, name, email, password, photo);
      });
    }
  }

  @override
  void initState() {
    readCurrentUserData();
    super.initState();
  }
  //=========================================================================
  @override
  Widget build(BuildContext context) {
    screenWidth= MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: DefaultColors.lightBarBackground,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.2,
                color: DefaultColors.primary,
              )
            ),
            Positioned(
              top: screenHeight * 0.05,
              bottom: screenHeight * 0.05,
              left: screenHeight * 0.05,
              right: screenHeight * 0.05,
              child: ChatArea(currentUserData: currentUserData),
            )
          ],
        ),
      )
    );
  }
}
