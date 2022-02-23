import 'package:flutter/cupertino.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? img;
  String? file;

  MessageModel({this.messageid,this.sender, this.text, this.seen, this.createdon,this.img,this.file});

  MessageModel.fromMap(Map<String, dynamic>map){
    messageid=map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    img=map["img"];
    file=map["file"];
  }
  Map<String,dynamic> toMap(){
    return{
      "messageid":messageid,
      "sender":sender,
      "text":text,
      "seen":seen,
      "createdon":createdon,
      "img":img,
      "file":file,
    };
  }
}