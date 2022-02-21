import 'package:chat_app/models/uihelper.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();

  void checkValue(){
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    if(email=="" || password == ""){
      UiHelper.showAlertDialog(context, "incompelete Data!", "please fill all the fields!");
    }
    else{
      login(email, password);
    }

  }


  void login(String email,String password) async{
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Logging In...");
    
    try{
      credential=await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
    }on FirebaseAuthException catch(ex){
      //close the loadingdialog

      Navigator.pop(context);
      //show alert dialoge
      UiHelper.showAlertDialog(context, "An Error occured!", ex.message.toString());

    }

    if(credential!=null){
      String uid=credential.user!.uid;
      DocumentSnapshot userData=await FirebaseFirestore.instance.collection('users')
          .doc(uid)
          .get();
      UserModel userModel=UserModel.fromMap(userData.data()as Map<String,dynamic>);

      print("login successfully");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context){
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));

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
                SizedBox(height: 20),
                CupertinoButton(child: Text("Login"),
                  onPressed: (){
                  checkValue();
                  },
                  color: Theme.of(context).colorScheme.secondary,)
              ],
            ),
          )),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an Accont?",style: TextStyle(fontSize: 16),),

          CupertinoButton(
            child: Text("Sign Up",style: TextStyle(fontSize: 16),),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return SignUpPage();
                  }
                  ),
                  );
                },)
          ],
        ),
      ),
    );
  }
}
