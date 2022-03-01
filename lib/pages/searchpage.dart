import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroommodel.dart';
import 'package:chat_app/pages/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/usermodel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller = TextEditingController();

  Future<ChatRoomModel?> getchatRoomModel(UserModel targetUser)async{
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("chatrooms")
        .where("participants.${widget.userModel.uid}",
         isEqualTo: true
        ).where("participants.${targetUser.uid}",
          isEqualTo: true).get();

    if(snapshot.docs.length > 0){
      //fetch the existing one
      var docData=snapshot.docs[0].data();
      ChatRoomModel existingchatroom=ChatRoomModel.fromMap(docData as Map<String,dynamic>);
      chatRoom=existingchatroom;
      //log("chat room already created!");
    }
    else{
      //create new one
      ChatRoomModel newChatRoom=ChatRoomModel(
      chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString():true,
            targetUser.uid.toString():true,
        },
      );
      await FirebaseFirestore.instance.collection("chatrooms")
          .doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
      chatRoom=newChatRoom;

      log("new chat room created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchcontroller,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text("search"),
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: searchcontroller.text)
                    .where("email",isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {

                      QuerySnapshot datasnapshot =
                          snapshot.data as QuerySnapshot;
                      if (datasnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap =
                            datasnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchedUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel=await
                            getchatRoomModel(searchedUser);
                            if(chatroomModel!=null){
                               Navigator.pop(context);
                               Navigator.push(context,
                                   MaterialPageRoute(builder: (context) {
                                 return ChatRoomPage(
                                   targetUser: searchedUser,
                                   userModel: widget.userModel,
                                   firebaseUser: widget.firebaseUser,
                                   chatroom:chatroomModel ,
                                 );
                               }));
                            }

                          },
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchedUser.profilepic!),
                            backgroundColor: Colors.green[500],
                          ),
                          title: Text(searchedUser.fullname.toString()),
                          subtitle: Text(searchedUser.email.toString()),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return Text("No results Founds");
                      }
                    } else if (snapshot.hasError) {
                      return Text("An Error Occured!");
                    } else {
                      return Text("No results Founds");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
