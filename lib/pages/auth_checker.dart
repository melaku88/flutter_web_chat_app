import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/pages/home_page.dart';
import 'package:flutter_web_chat_app/pages/login_register.dart';

class AuthCheckerPage extends StatefulWidget {
  const AuthCheckerPage({super.key});

  @override
  State<AuthCheckerPage> createState() => _AuthCheckerPageState();
}

class _AuthCheckerPageState extends State<AuthCheckerPage> {
  // ========================================
  String? currentUser;
  onloading()async{
    currentUser = await FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      
    });
  }
  @override
  void initState() {
    onloading();
    super.initState();
  }
  // ========================================
  @override
  Widget build(BuildContext context) {
    if(currentUser == null){
      return LoginRegisterPage();
    }else{
      return HomePage();
    }
  }
}