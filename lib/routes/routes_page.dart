import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';
import 'package:flutter_web_chat_app/pages/auth_checker.dart';
import 'package:flutter_web_chat_app/pages/home_page.dart';
import 'package:flutter_web_chat_app/pages/login_register.dart';
import 'package:flutter_web_chat_app/pages/messages_page.dart';

class RoutesPage{
  static Route<dynamic> createRoutes(RouteSettings settingsRoute){
    final arguments = settingsRoute.arguments;
    switch(settingsRoute.name){
      case '/':
        return MaterialPageRoute(builder: (context) => AuthCheckerPage());
      case '/login':
        return MaterialPageRoute(builder: (context) => LoginRegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/messages':
        return MaterialPageRoute(builder: (context) => MessagePage(arguments as UserModel));
    }
    return errorPageRoute();
  }
  static Route<dynamic> errorPageRoute(){
    return MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(
          title: Text('Web page not found'),
        ),
        body: Center(
          child: Text('Web Page Not Found!'),
        ),
      );
    });
  }
}