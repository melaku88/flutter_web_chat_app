import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/models/message_model.dart';
import 'package:flutter_web_chat_app/models/recnt_chat.dart';
import 'package:flutter_web_chat_app/models/user_model.dart';
import 'package:flutter_web_chat_app/provider/provider_chat.dart';
import 'package:provider/provider.dart';

class MessagesWidget extends StatefulWidget {
  final UserModel fromUserData;
  final UserModel toUserData;
  const MessagesWidget({
    super.key,
    required this.toUserData,
    required this.fromUserData
    });

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  // =====================================================================================================================

  final TextEditingController _messageTextController = TextEditingController();
  late StreamSubscription _streamSubscriptionMessages;
  final  streamController = StreamController<QuerySnapshot>.broadcast();
  final scrollControllerMessages = ScrollController();
  String? fileTypeChoosed;
  bool _loadingPic = false;
  bool _loadingFile = false;
  Uint8List? _selectedImage;
  Uint8List? _selectedFile;

  sendMessage()async{
    String msgText = _messageTextController.text.trim();
    if(msgText.isNotEmpty){

      String fromUserId = widget.fromUserData.uid;
      String toUserId = widget.toUserData.uid;
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();

      final messageData = MessageModel(
        fromUserId, 
        msgText, 
        Timestamp.now()
      );

      final recentChatFromData = RecentChatModel(
        fromUserId, 
        toUserId, 
        widget.toUserData.name, 
        widget.toUserData.email, 
        widget.toUserData.profilePic, 
        _messageTextController.text.trim()
      );
      final recentChatToData = RecentChatModel(
        toUserId, 
        fromUserId, 
        widget.fromUserData.name, 
        widget.fromUserData.email, 
        widget.fromUserData.profilePic, 
        _messageTextController.text.trim()
      );

      // Save message for sender
      saveMessageToDatabase(fromUserId, toUserId, messageId, messageData);

      // Save message for receiver
      saveMessageToDatabase(toUserId, fromUserId, messageId, messageData);

      // Save recent chat for sender
      saveRecentChatToDatabase(recentChatFromData, msgText);

      // save recent chat for receiver
      saveRecentChatToDatabase(recentChatToData, msgText);

    }

  }

  saveMessageToDatabase(fromUserId, toUserId, messageId,MessageModel messageData)async{
    await FirebaseFirestore.instance
      .collection('Messages')
      .doc(fromUserId)
      .collection(toUserId)
      .doc(messageId)
      .set(messageData.toJson());

      _messageTextController.clear();
  }

  saveRecentChatToDatabase(RecentChatModel recentChat, text)async{
    await FirebaseFirestore.instance
      .collection('RecentChats')
      .doc(recentChat.fromUserId)
      .collection('lastMessage')
      .doc(recentChat.toUserId)
      .set(recentChat.toJson()).then((value){
        //  send notification
      });
  }


  createMessageStream({UserModel? toUserData}){
    final streamMessages = FirebaseFirestore.instance
      .collection('Messages')
      .doc(widget.fromUserData.uid)
      .collection(toUserData?.uid ?? widget.toUserData.uid)
      .orderBy('date', descending: false)
      .snapshots();

  // Scroll at the end of message list
      _streamSubscriptionMessages = streamMessages.listen((event) { 
        streamController.add(event);
        Timer(Duration(seconds: 1), () { 
          scrollControllerMessages.jumpTo(scrollControllerMessages.position.maxScrollExtent);
        });
      });
  }

  updateMessageListener(){
    UserModel? toUserData = context.watch<ProviderChat>().toUserData;
    if(toUserData != null){
      createMessageStream(toUserData: toUserData);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMessageListener();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionMessages.cancel();
  }

  @override
  void initState() {
    super.initState();
    createMessageStream();
  }
  // ==========================================================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/backgrounds.png'),
          fit: BoxFit.cover
        ),
      ),
      child: Column(
        children: [
          // display message
          StreamBuilder(
            stream: streamController.stream, 
            builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.none:
                case ConnectionState.waiting:
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Loading Messages...'),
                        SizedBox(height: 10.0,),
                        CircularProgressIndicator(),
                      ],
                    ),
                  )
                );
                case ConnectionState.active:
                case ConnectionState.done:
                if(snapshot.hasError){
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error on loading messages')
                        ],
                      ),
                    )
                  );
                }else{
                  final snaps = snapshot.data as QuerySnapshot;
                  List<DocumentSnapshot> messsagesList = snaps.docs;
                  if(messsagesList.length != 0){
                    return Expanded(
                      child: ListView.builder(
                        controller: scrollControllerMessages,
                        itemCount: snaps.docs.length,
                        itemBuilder: (context, index){
                          DocumentSnapshot eachMessage = messsagesList[index];
                      
                          // align message baloons of senders and receivers
                          Alignment alignment = Alignment.bottomLeft;
                          Color color = const Color.fromARGB(255, 163, 251, 242);
                          Size width = MediaQuery.of(context).size*0.8;
                          if(widget.fromUserData.uid == eachMessage['uid']){
                            alignment = Alignment.bottomRight;
                            color = Color(0xffd2ffa5);
                          }
                          return GestureDetector(
                            onLongPress: () async{
                              await showDialog(
                                context: context, 
                                builder: (context){
                                  return AlertDialog(
                                    content: Text('Are you sure you want to delete this message?'),
                                    actions: [
                                      OutlinedButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          deleteForMe(
                                            widget.fromUserData.uid, 
                                            widget.toUserData.uid, 
                                            eachMessage.id, 
                                            eachMessage['message'].toString()
                                          );
                                          deleteForThem(
                                            widget.fromUserData.uid, 
                                            widget.toUserData.uid, 
                                            eachMessage.id, 
                                            eachMessage['message'].toString()
                                          );
                                        }, 
                                        child: Text('for everyone')
                                      ),
                                      OutlinedButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          deleteForMe(
                                            eachMessage['uid'], 
                                            widget.toUserData.uid, 
                                            eachMessage.id, 
                                            eachMessage['message'].toString()
                                          );
                                        }, 
                                        child: Text('for yourself')
                                      ),
                                      OutlinedButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        }, 
                                        child: Text('Cancel')
                                      )
                                    ],
                                  );
                                }
                              );
                            },
                            child: Align(
                              alignment: alignment, 
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(15.0),
                                    margin: EdgeInsets.all(6.0),
                                    constraints: BoxConstraints.loose(width),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.all(Radius.circular(9.0))
                                    ),
                                    child: eachMessage['message'].toString().contains('.jpg') ? Image.network(eachMessage['message'], width: 200.0, height: 200.0,) : eachMessage['message'].toString().contains('.pdf') 
                                    || eachMessage['message'].toString().contains('.mp4') 
                                    ||eachMessage['message'].toString().contains( '.mp3') 
                                    || eachMessage['message'].toString().contains('.docx') 
                                    || eachMessage['message'].toString().contains( '.pptx') 
                                    || eachMessage['message'].toString().contains( '.xlsx') ? Image.asset('images/file.png', height: 50.0, width: 50.0,) : Text(eachMessage['message'])
                                  ),
                                ],
                              )
                            ) 
                          );
                        }
                      ),
                    );
                  }else{
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No conversations yet!')
                          ],
                        ),
                      )
                    );
                  }
                }
              }
            }
          ),
          // display text writting field
          Container(
            color: Colors.grey.shade400,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    margin: EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40.0)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_emoticon),
                        SizedBox(width: 5.0,),
                        Expanded(
                          child: TextField(
                            controller: _messageTextController,
                            decoration: InputDecoration(
                              hintText: 'Write a message...',
                              border: InputBorder.none
                            ),
                          ),
                        ),
                        _loadingFile == false ? IconButton(
                          onPressed: (){
                            showDialogToSelectingFile();
                          }, 
                          icon: Icon(Icons.attach_file)
                        ) : Center(child: Container(
                          width: 18.0,
                          height: 18.0,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: CircularProgressIndicator(color: DefaultColors.primary, strokeWidth: 2.0,)
                        )),

                        _loadingPic == false ? IconButton(
                          onPressed: (){
                            selectImage();
                          }, 
                          icon: Icon(Icons.camera_alt)
                        ) : Center(child: Container(
                          width: 18.0,
                          height: 18.0,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: CircularProgressIndicator(color: DefaultColors.primary, strokeWidth: 2.0,)
                        )),
                      ],
                    ),
                  )
                ),
                FloatingActionButton(
                  onPressed: (){
                    sendMessage();
                  },
                  backgroundColor: DefaultColors.primary,
                  mini: true,
                  child: Icon(Icons.send, color: Colors.white,),
                )
              ],
            ),
          )
        ],
        
      ),
    );
  }
  
  showDialogToSelectingFile() {
    showDialog(context: context, 
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return AlertDialog(
              title: Text('Select & Send File'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please select the file type here!'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      hint: Text('Choose file-type'),
                      value: fileTypeChoosed,
                      underline: Container(),
                      items: <String>['.pdf', '.mp4', '.mp3', '.docx', '.pptx', '.xlsx'].map((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value)
                        );
                      }).toList(), 
                      onChanged: (String? value) { 
                        setState((){
                          fileTypeChoosed = value;
                        });
                       },
                    ),
                  )
                ],
              ),
              actions: [
                OutlinedButton(onPressed: (){
                  // Select file
                  selectFile(fileTypeChoosed);
                }, 
                child: Text('Select File')
              )
      
              ],
            );
          }
        );
      });
  }
  
  selectFile(String? fileTypeChoosed) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    setState(() {
      _selectedFile = result?.files.single.bytes;
    });

    // upload file
    if(_selectedFile != null){
      Navigator.of(context).pop();
      setState(() {
        _loadingFile = true;
      });
      Reference fileRef = FirebaseStorage
        .instance
        .ref('files/${DateTime.now().millisecondsSinceEpoch.toString()}$fileTypeChoosed');

      UploadTask task = fileRef.putData(_selectedFile!);
      task.whenComplete(() async{
        String linkText = await task.snapshot.ref.getDownloadURL();
        setState(() {
          _messageTextController.text = linkText;
        });
        sendMessage();
        setState(() {
          _loadingFile = false;
        });
      });
    }
  }


  selectImage() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    setState(() {
      _selectedImage = result?.files.single.bytes;
    });

    // upload file
    if(_selectedImage != null){
      setState(() {
        _loadingPic = true;
      });
      Reference fileRef = FirebaseStorage
        .instance
        .ref('chatImages/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');

      UploadTask task = fileRef.putData(_selectedImage!);
      task.whenComplete(() async{
        String linkImage = await task.snapshot.ref.getDownloadURL();
        setState(() {
          _messageTextController.text = linkImage;
        });
        sendMessage();
        setState(() {
          _loadingPic = false;
        });
      });
    }
  }
  
  deleteForMe(fromUid, toUid, messageId, messageText)async{
    await FirebaseFirestore.instance
      .collection('Messages')
      .doc(fromUid)
      .collection(toUid)
      .doc(messageId)
      .delete();
  }
  deleteForThem(fromUid, toUid, messageId, messageText)async{
    await FirebaseFirestore.instance
      .collection('Messages')
      .doc(toUid)
      .collection(fromUid)
      .doc(messageId)
      .delete();
  }
}
