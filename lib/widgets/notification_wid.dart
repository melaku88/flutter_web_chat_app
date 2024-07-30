import 'package:flutter/material.dart';

class NotificationWidget extends StatefulWidget {
  final title;
  final body;
  const NotificationWidget({super.key, required this.title, required this.body});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      actions: [
        OutlinedButton.icon(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          icon: Icon(Icons.close), 
          label: Text('Close'),
        )
      ],
      content: widget.body.toString().contains('.jpg') 
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sent you an image'),
            SizedBox(height: 10.0,),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Image.network(widget.body.toString(), height: 100.0, width: 100.0,),
            )
          ],
        )
        : widget.body.toString().contains('.pdf')
        || widget.body.toString().contains('.mp4')
        || widget.body.toString().contains('.mp3')
        || widget.body.toString().contains('.docx')
        || widget.body.toString().contains('.pptx')
        || widget.body.toString().contains('.xlsx') 
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sent you a file'),
            SizedBox(height: 10.0,),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Image.asset('images/file.png', height: 50.0, width: 50.0,),
            )
          ],
        )
        : Text(widget.body),
    );
  }
}