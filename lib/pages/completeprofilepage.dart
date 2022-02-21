import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfilePage({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);
  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
   File? imageFile;
  TextEditingController fullNameController=TextEditingController();


 void SelectImage(ImageSource source) async{
  XFile? pickFile = await ImagePicker().pickImage(source: source);
  if(pickFile!=null){
    CropImage(pickFile);
  }

 }
 void CropImage(XFile file) async{
   File? CroppedImage= await ImageCropper.cropImage(
       sourcePath: file.path,
     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
     compressQuality: 20,


   );
   if(CroppedImage!=null){
     setState(() {
       imageFile=CroppedImage;
     });
   }

 }
  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                SelectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title:Text("Select from gallary"),
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                SelectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title:Text("Take a Photo"),
            )
          ],
        ),
      );
    });
  }
  void CheckValues(){
    String fullname=fullNameController.text.trim();

    if(fullname=="" || imageFile==null){
    UiHelper.showAlertDialog(context, "Incomplete Data!", "Please fill all the fields! "
        "and upload profile pic");
    }
    else{
      log("uplaoding data....");
      uploadData();
    }
  }

  void uploadData() async{
   UiHelper.showLoadingDialog(context, "Uploading image...");
    UploadTask uploadTask=FirebaseStorage.instance.ref("profilepicture")
        .child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot= await uploadTask;
    String imageUrl= await snapshot.ref.getDownloadURL();
    String fullname=fullNameController.text.trim();

    widget.userModel.fullname=fullname;
    widget.userModel.profilepic=imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid)
        .set(widget.userModel.toMap()).then((value){
          log("Data uploaded!");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CompleteProfile"),
        automaticallyImplyLeading: false,
        centerTitle:true,
      ),
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: (){
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  backgroundImage: (imageFile!=null)? FileImage(imageFile!):null,
                  radius: 60,
                  child: (imageFile==null)? Icon(Icons.person,size: 60,
                  ):null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text("Submit",style: TextStyle(fontSize: 16),),
                onPressed: (){
                  CheckValues();
                },
                color: Theme.of(context).colorScheme.secondary,),
            ],
          ),
        ),
      ),
    );
  }
}
