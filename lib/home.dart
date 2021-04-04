import 'package:chatter_app/auth.dart';
import 'package:chatter_app/database.dart';
import 'package:chatter_app/shared.dart';
import 'package:chatter_app/views/chatscreen.dart';
import 'package:chatter_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;
  String myName, myProfilepic, myusername,myEmail;
  Stream usersStream,chatRoomsStream;
  TextEditingController searchUsernameEditingController = TextEditingController();

  getMyInfoFromSharedPrefence() async{
    myName = await SharedPreferenceHelper().getDisplaName();
    myProfilepic = await SharedPreferenceHelper().getUserProfileUrl();
    myusername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

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

  onSearchBtnClick() async{
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUsername(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget chatRoomsList()
  {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context,snapshot){
          return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return ChatRoomListTile(ds.data()["lastMessage"], ds.id , myusername);
              }):Center(child: CircularProgressIndicator(),);
        });
  }

  Widget searchListUserTile(String profileUrl,name,email,username){
    return GestureDetector(
      onTap: ()
      {
        var chatRoomId = getChatRoomIdByUsernames(myusername, username);
        Map< String, dynamic> chatRoomInfoMap = {
          "users" : [myusername,username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(username,name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(width: 12,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(email),
            ],
          )
        ],
      ),
    );
  }

  Widget searchUsersList(){
    return StreamBuilder(
        stream: usersStream,
        builder: (context,snapshot){
          return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data.docs[index];
                return searchListUserTile(
                     ds.data()["imgUrl"],ds.data()["name"],ds.data()["email"],ds.data()["username"]);
              },
          ) : Center(child: CircularProgressIndicator(),);
        },
    );
  }


  getChatRooms() async{
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  // Widget chatRoomListTile(String profilePicture,String name, String lastMessage)
  // {
  //   return
  // }

  onScreenLoaded() async{
    await getMyInfoFromSharedPrefence();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text("Messenger Clone",style: TextStyle(
            color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.w600
        ),),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: (){
                AuthMethods().signOut().then((s) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app,color: Colors.black,)),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                isSearching ? GestureDetector(
                  onTap: (){
                    isSearching = false;
                    searchUsernameEditingController.text=" ";
                    setState(() {

                    });
                  },
                  child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_back)
                  ),
                ):Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black87,
                          width: 1.0,
                          style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(24)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                             controller: searchUsernameEditingController,
                            decoration: InputDecoration(border: InputBorder.none,hintText: "UserName"),
                          ),
                        ),
                        GestureDetector(
                            onTap: (){
                              if(searchUsernameEditingController.text != ""){
                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList(),
          ],
        )
      ),
      );
  }
  }
  
class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myusername;

  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myusername);
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {

  String profilePicture,name,username;

  getThisUserInfo() async{
    username  = widget.chatRoomId.replaceAll(widget.myusername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print("something ${querySnapshot.docs[0].id} ${querySnapshot.docs[0] ["name"]} ${querySnapshot.docs[0] ["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicture = "${querySnapshot.docs[1]["imgUrl"]}";
    setState(() {

    });
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(profilePicture,height: 40,width: 40,)),
        SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,style: TextStyle(fontSize: 16),),
            SizedBox(height: 3,),
            Text(widget.lastMessage)
           ],
        )
      ]
    );
  }
}

