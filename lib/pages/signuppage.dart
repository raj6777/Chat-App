import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/completeprofilepage.dart';
import 'package:chat_app/pages/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController= TextEditingController();
  TextEditingController passwordController= TextEditingController();
  TextEditingController cpasswordController= TextEditingController();

  void checkValues(){
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    String cpasswor=cpasswordController.text.trim();

    if(email=="" || password=="" || cpasswor==""){
      UiHelper.showAlertDialog(context, "incompelete data!", "Please fill all the fields!");
    }
    else if(password!=cpasswor){
      UiHelper.showAlertDialog(context, "Password MisMatch!", "The password you have do not match!");
    }
    else{
      signUp(email, password);
    }
  }

  void signUp(String email,String password) async{
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "creating new account...");
    try{
      credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An Error occured", ex.message.toString());
    }
    if(credential!=null){
      String uid= credential.user!.uid;
      UserModel newUser=UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance.collection("users").doc(uid)
          .set(newUser.toMap())
          .then((value) {
            print("New User Created!");
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return CompleteProfilePage(userModel: newUser, firebaseUser: credential!.user!);
            }));
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Chat App",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: cpasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                  ),
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  child: Text("Sign Up"),
                  onPressed: () {
                    checkValues();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                )
              ],
            ),
          )),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an Account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              child: Text(
                "Log in",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
