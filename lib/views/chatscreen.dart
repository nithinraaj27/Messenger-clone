import 'package:chatter_app/database.dart';
import 'package:chatter_app/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'signin.dart';

class ChatScreen extends StatefulWidget {
  final String chatwithUsername, name;

  const ChatScreen(this.chatwithUsername, this.name);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String chatRoomId, messageId = "";
  Stream messageStream;
  String myName, myProfilepic, myusername,myEmail;
  TextEditingController messageTextEdittingController = TextEditingController();

  getMyInfoFromSharedPrefence() async{
    myName = await SharedPreferenceHelper().getDisplaName();
    myProfilepic = await SharedPreferenceHelper().getUserProfileUrl();
    myusername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(widget.chatwithUsername, myusername);
  }


  getChatRoomIdByUsernames(String a,String b)
  {
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return  "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }

  Widget chatMessageTile(String message,bool sendByMe)
  {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16,vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24),
            bottomRight: sendByMe? Radius.circular(0):Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: sendByMe? Radius.circular(24) : Radius.circular(0),
            ),
            color: Colors.blue
          ),
          padding: EdgeInsets.all(16),
          child: Text(message,style: TextStyle(color: Colors.white),),),
      ],
    );
  }

  Widget chatMessages()
  {
    return StreamBuilder(
        stream: messageStream,
        builder: (context,snapshot){
          return snapshot.hasData ? ListView.builder(
            padding: EdgeInsets.only(bottom: 70,top: 16),
              itemCount: snapshot.data.docs.length,
              reverse: true,
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return chatMessageTile(ds.data()["message"],myusername == ds.data()["sendBy"]);
              }): Center(child: CircularProgressIndicator(),);
        },
    );
  }

  getAndSetMessages() async{
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {

    });
  }

  doThisOnLaunch() async
  {
    await getMyInfoFromSharedPrefence();
    getAndSetMessages();
  }

  addMessage(bool sendClicked){
    if(messageTextEdittingController.text != ""){
      String message = messageTextEdittingController.text;
      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message" : message,
        "sendBy"  : myusername,
        "ts" : lastMessageTs,
        "imgUrl" : myProfilepic,
      };

      //messageId
      if(messageId == ""){
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods().addmessage(chatRoomId, messageId, messageInfoMap).then((value){

        Map<String,dynamic> lastMessageInfomap = {
          "lastMessage" : message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy" : myusername
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfomap);

        if(sendClicked){
          messageTextEdittingController.text = '';
          messageId = "";

        }
      });
    }
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name),),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageTextEdittingController,
                          onChanged: (value){
                            addMessage(false);
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(border: InputBorder.none,
                          hintText: "Type a message",
                            hintStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white.withOpacity(0.6))
                          )
                        )),
                    GestureDetector(
                        onTap: (){
                          addMessage(true);
                        },
                        child: Icon(Icons.send,color: Colors.white,))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
