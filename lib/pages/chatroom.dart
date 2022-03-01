// import 'dart:developer';
// import 'dart:io';
//
// import 'package:chat_app/main.dart';
// import 'package:chat_app/models/chatroommodel.dart';
// import 'package:chat_app/models/messagemodel.dart';
// import 'package:chat_app/models/usermodel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
//
// class ChatRoomPage extends StatefulWidget {
//   final UserModel targetUser;
//   final ChatRoomModel chatroom;
//   final UserModel userModel;
//   final User firebaseUser;
//
//   const ChatRoomPage(
//       {Key? key,
//         required this.targetUser,
//         required this.chatroom,
//         required this.userModel,
//         required this.firebaseUser})
//       : super(key: key);
//
//   @override
//   _ChatRoomPageState createState() => _ChatRoomPageState();
// }
//
// class _ChatRoomPageState extends State<ChatRoomPage> {
//   TextEditingController messageController = TextEditingController();
//
//
//   File? imageFile;
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future SelectImage() async {
//     XFile? pickFile =
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickFile != null) {
//       CropImage(pickFile);
//     }
//   }
//
//   Future CropImage(XFile file) async {
//     File? CroppedImage = await ImageCropper.cropImage(
//       sourcePath: file.path,
//       aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
//       compressQuality: 20,
//     );
//     if (CroppedImage != null) {
//       imageFile = CroppedImage;
//       uploadImage();
//     }
//   }
//
//   Future uploadImage() async {
//     String fileName = Uuid().v1();
//     int status = 1;
//
//     await _firestore
//         .collection('chatrooms')
//         .doc(widget.chatroom.chatroomid)
//         .collection('messages')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });
//
//     var ref =
//     FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
//
//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatrooms')
//           .doc(widget.chatroom.chatroomid)
//           .collection('messages')
//           .doc(fileName)
//           .delete();
//
//       status = 0;
//     });
//
//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();
//
//       await _firestore
//           .collection('chatrooms')
//           .doc(widget.chatroom.chatroomid)
//           .collection('messages')
//           .doc(fileName)
//           .update({"message": imageUrl});
//
//       print(imageUrl);
//     }
//   }
//
//   void sendmessage() async {
//     String msg = messageController.text.trim();
//     messageController.clear();
//     if (msg != "") {
//       //send message
//       MessageModel newMessage = MessageModel(
//         messageid: uuid.v1(),
//         sender: widget.userModel.uid,
//         createdon: DateTime.now(),
//         text: msg,
//         seen: false,
//       );
//       FirebaseFirestore.instance
//           .collection("chatrooms")
//           .doc(widget.chatroom.chatroomid)
//           .collection("messages")
//           .doc(newMessage.messageid)
//           .set(newMessage.toMap());
//       widget.chatroom.lastMessage = msg;
//       FirebaseFirestore.instance.collection("chatrooms").doc(
//           widget.chatroom.chatroomid)
//           .set(widget.chatroom.toMap());
//       log("Message sent!");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.grey,
//               backgroundImage:
//               NetworkImage(widget.targetUser.profilepic.toString()),
//             ),
//             SizedBox(width: 10),
//             Text(widget.targetUser.fullname.toString()),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection("chatrooms")
//                         .doc(widget.chatroom.chatroomid)
//                         .collection("messages")
//                         .orderBy("createdon", descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.active) {
//                         if (snapshot.hasData) {
//                           QuerySnapshot datasnapshot =
//                           snapshot.data as QuerySnapshot;
//                           return ListView.builder(
//                               reverse: true,
//                               itemCount: datasnapshot.docs.length,
//                               itemBuilder: (context, index) {
//                                 MessageModel currentMessage =
//                                 MessageModel.fromMap(
//                                     datasnapshot.docs[index].data()
//                                     as Map<String, dynamic>);
//                                 return Row(
//                                     mainAxisAlignment: (currentMessage.sender ==
//                                         widget.userModel.uid)
//                                         ? MainAxisAlignment.end
//                                         : MainAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                           margin:
//                                           EdgeInsets.symmetric(vertical: 2),
//                                           padding: EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 10),
//                                           decoration: BoxDecoration(
//                                             color: (currentMessage.sender ==
//                                                 widget.userModel.uid)
//                                                 ? Colors.grey
//                                                 : Theme
//                                                 .of(context)
//                                                 .colorScheme
//                                                 .secondary,
//                                             borderRadius:
//                                             BorderRadius.circular(5),
//                                           ),
//                                           child: Text(
//                                             currentMessage.text.toString(),
//                                             style: TextStyle(
//                                                 color: Colors.white),
//                                           )),Container(
//                                                   child:
//                                                   Image.network(
//                                                     currentMessage.img.toString(),
//                                                     fit: BoxFit.fitWidth,
//                                                   ),
//                                                   height: 150,
//                                                   width: 150.0,
//                                                   color: Color.fromRGBO(
//                                                       0, 0, 0, 0.2),
//                                                   padding: EdgeInsets.all(5),
//                                                 )
//                                     ]);
//                               });
//                         } else if (snapshot.hasError) {
//                           return Center(
//                               child: Text("An Error Occured! please check your"
//                                   " internet connection"));
//                         } else {
//                           return Center(
//                               child: Text("say hi ti your new friend"));
//                         }
//                       } else {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                 color: Colors.grey[200],
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                 child: Row(
//                   children: [
//                     Flexible(
//                       child: TextField(
//                         controller: messageController,
//                         maxLines: null,
//                         decoration: InputDecoration(
//                           prefixIcon: IconButton(
//                                 onPressed: () {
//                                  SelectImage();
//                                },
//                                icon: Icon(Icons.photo),
//                              ),
//                             border: InputBorder.none,
//                             hintText: "Enter Message"),
//                       ),
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           sendmessage();
//                         },
//                         icon: Icon(
//                           Icons.send,
//                           color: Theme
//                               .of(context)
//                               .colorScheme
//                               .secondary,
//                         ))
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chatroommodel.dart';
import 'package:chat_app/models/messagemodel.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/pdfviewer.dart';
import 'package:chat_app/pages/signaling.dart';
import 'package:chat_app/pages/videoscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/uihelper.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  File? imageFile;
  File? pdfFile;
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;

  void selectfile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);
    if (result != null) {
      File file = File(result.files.first.path.toString());
      pdfFile = file;
      UiHelper.showAlertDialog(
          context, file.path.split('/').last + ' Picked', 'Press sent button');
    } else {
      print("file will be cancel");
    }
  }

  void SelectImage() async {
    XFile? pickFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickFile != null) {
      CropImage(pickFile);
    }
  }

  void CropImage(XFile file) async {
    File? CroppedImage = await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (CroppedImage != null) {
      imageFile = CroppedImage;
      //uploadData();
    }
  }

  void sendmessage() async {
    String msg = messageController.text.trim();

    messageController.clear();
    if (pdfFile != null && msg == "" && imageFile == null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '-' +
          pdfFile!.path.split('/').last;
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("Chat_files")
          .child(fileName)
          .putFile(pdfFile!);
      TaskSnapshot snapshot = await uploadTask;
      String pdfUrl = await snapshot.ref.getDownloadURL();
      if (pdfUrl != null) {
        log(pdfUrl);
        MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          seen: false,
          file: pdfUrl,
          type: "pdf",
        );
        FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .collection("messages")
            .doc(newMessage.messageid)
            .set(newMessage.toMap());
        widget.chatroom.lastMessage = msg == null ? msg.toString() : 'file';
        FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .set(widget.chatroom.toMap());
        log("file sent!");
      }
    }
    if (msg != "" && imageFile == null && pdfFile == null) {
      log(msg);
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
        type: 'msg',
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      log("Message sent!");
    }
    if (imageFile != null && msg == "" && pdfFile == null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("Chat_images")
          .child(fileName)
          .putFile(imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      if (imageUrl != null) {
        log(imageUrl);
        MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          img: imageUrl,
          seen: false,
          type: "img",
        );
        FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .collection("messages")
            .doc(newMessage.messageid)
            .set(newMessage.toMap());
        widget.chatroom.lastMessage = msg == null ? msg.toString() : 'Photo';
        FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .set(widget.chatroom.toMap());
        log("Image sent!");
      }
    }
  }

  String convertFile(name) {
    //https://firebasestorage.googleapis.com/v0/b/chat-app-c0eca.appspot.com/o/Chat_images%2F1645521440920-hey?alt=media&token=fc400d49-eec3-4ddd-84d4-ffd1962d5f50
    var temp = name.split("/")[7];
    var starttext = '%2F';
    var start = temp.indexOf(starttext);
    var end = temp.indexOf('?');
    var finalst = temp.substring(start + starttext.length, end).trim();
    return finalst.split('-').last;
  }

  @override
  void initState() {
    // TODO: implement initState
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            SizedBox(width: 10),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await signaling.openUserMedia(_localRenderer, _remoteRenderer);
                roomId = await signaling.createRoom(_remoteRenderer);
                MessageModel vcMsg = MessageModel(
                  messageid: uuid.v1(),
                  sender: widget.userModel.uid,
                  createdon: DateTime.now(),
                  text: roomId,
                  seen: false,
                  type: "vc",
                );
                FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("messages")
                    .doc(vcMsg.messageid)
                    .set(vcMsg.toMap());
                widget.chatroom.lastMessage = roomId;
                FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .set(widget.chatroom.toMap());
                log("Message sent!");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoScreen(
                      roomId: roomId,
                      signaling: signaling,
                      chatRoomId: widget.chatroom.chatroomid,
                      localRenderer: _localRenderer,
                      remoteRenderer: _remoteRenderer,
                      msgId: vcMsg.messageid,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.video_call))
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot datasnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                              reverse: true,
                              itemCount: datasnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        datasnapshot.docs[index].data()
                                            as Map<String, dynamic>);

                                return Row(
                                    mainAxisAlignment: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 2),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? Colors.blueGrey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: currentMessage.img != null
                                              ? Container(
                                                  child: Image.network(
                                                    currentMessage.img
                                                        .toString(),
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                  height: 150,
                                                  width: 150.0,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.2),
                                                  padding: EdgeInsets.all(5),
                                                )
                                              : currentMessage.file != null
                                                  ? Container(
                                                      child: InkWell(
                                                        child: Text(
                                                          convertFile(
                                                              currentMessage
                                                                  .file
                                                                  .toString()),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onTap: (() => {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return PdfViewer1(
                                                                    url: currentMessage
                                                                        .file
                                                                        .toString());
                                                              }))
                                                            }),
                                                      ),
                                                    )
                                                  : currentMessage.type == "vc"
                                                      ? TextButton(
                                                          child: Text("Accept"),
                                                          onPressed: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        VideoScreen(
                                                                  roomId:
                                                                      roomId,
                                                                  signaling:
                                                                      signaling,
                                                                  chatRoomId: widget
                                                                      .chatroom
                                                                      .chatroomid,
                                                                  localRenderer:
                                                                      _localRenderer,
                                                                  remoteRenderer:
                                                                      _remoteRenderer,
                                                                  msgId: widget
                                                                      .userModel
                                                                      .uid,
                                                                ),
                                                              ),
                                                            );
                                                            await signaling
                                                                .openUserMedia(
                                                                    _localRenderer,
                                                                    _remoteRenderer);
                                                            await signaling.joinRoom(
                                                                currentMessage
                                                                    .text
                                                                    .toString(),
                                                                _remoteRenderer);
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary:
                                                                Colors.black,
                                                            backgroundColor: Colors
                                                                .lightGreenAccent, // Background Color
                                                          ),
                                                        )
                                                      : Text(
                                                          currentMessage.text
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                    ]);
                              });
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("An Error Occured! please check your"
                                  " internet connection"));
                        } else {
                          return Center(
                              child: Text("say hi ti your new friend"));
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () {
                                SelectImage();
                              },
                              icon: Icon(Icons.photo),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  selectfile();
                                },
                                icon: Icon(Icons.file_copy_outlined)),
                            border: InputBorder.none,
                            hintText: "Enter Message"),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          sendmessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
