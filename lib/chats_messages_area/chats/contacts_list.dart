import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  // ==========================================================================================
  String currentUserId = '';

  getCurrentUser(){
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      setState(() {
        currentUserId = currentUser.uid;
      });
    }
  }

  Future<List<UserModel>> readContactList()async{
    QuerySnapshot allUsersRecord = await FirebaseFirestore.instance.collection('Users').get();
    List<UserModel> allUsersList = [];

    for(DocumentSnapshot userRecords in allUsersRecord.docs){
      String uid = userRecords['uid'];
      if(uid == currentUserId){
        continue;
      }
      String name = userRecords['name'];
      String email = userRecords['email'];
      String password = userRecords['password'];
      String profilePic = userRecords['profilePic'];

      UserModel userData = UserModel(uid, name, email, password, profilePic);
      allUsersList.add(userData);

    }
    return allUsersList;
  }


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  // ==========================================================================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readContactList(),
      builder:((context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Loading Contacts'),
                  SizedBox(height: 10.0,),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
          case ConnectionState.active:
          case ConnectionState.done:
          if(snapshot.hasError){
            return Center(
              child: Text(
                'Error on loading contact list!',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.red),
                ),
            );
          }else{
            List<UserModel>? userContactList = snapshot.data;
            if(userContactList != null){
              return ListView.separated(
                itemCount: userContactList.length,
                separatorBuilder: (context, index){
                  return Divider(thickness: 0.3, color: Colors.grey.shade300,);
                }, 
                itemBuilder: (context, index){
                  UserModel userData = userContactList[index];

                  return ListTile(
                    onTap: () {
                      Future.delayed(Duration.zero, (){
                        Navigator.pushNamed(context, '/messages', arguments: userData);
                      });
                    },
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(userData.profilePic.toString()),
                    ),
                    title: Text(
                      userData.name.toString(),
                      style: TextStyle(),
                    ),
                    contentPadding: EdgeInsets.all(8.0),
                  );
                }, 
              );
            }else{
              return Center(
                child: Text(
                  'No user found!',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
              );
            }
          }
        }
      }),
    );
  }
}