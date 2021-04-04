import 'package:chatter_app/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class DatabaseMethods{
  
  Future addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async{

     return FirebaseFirestore.instance
         .collection("users")
         .doc(userId)
         .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUsername(String username) async{
    return FirebaseFirestore.instance
        .collection("users")
        .where("username",isEqualTo: username)
        .snapshots();
  }

  Future addmessage(String chatRoomId,String messageId,Map messageInfoMap) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, Map lastMessageInfoMap){
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  createChatRoom(String chatRoomId,Map chatRoomInfoMap) async{
    final snapShot = await FirebaseFirestore.instance
    .collection("chatrooms")
    .doc(chatRoomId)
    .get();

    if(snapShot.exists){
      return true;
    }else
      {
        return FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(chatRoomId)
            .set(chatRoomInfoMap);
      }
  }
  
  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts",descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async{
    String myName = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs",descending: true)
        .where("users",arrayContains: myName)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username)
  {
    FirebaseFirestore.instance
        .collection("users")
        .where("username",isEqualTo: username)
        .get();
  }
}