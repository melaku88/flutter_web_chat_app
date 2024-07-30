import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';

class ProviderChat with ChangeNotifier{

  UserModel? _toUserData;

  UserModel? get toUserData => _toUserData;

  set toUserData(UserModel? userDataModel){
    _toUserData = userDataModel;
    notifyListeners();
  }
  }