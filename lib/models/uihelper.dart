import 'package:flutter/material.dart';

class UiHelper{
  static void showLoadingDialog(BuildContext context,String title){
    AlertDialog loadingdialog=AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30),
            Text(title),
          ],
        ),
      ),
    );
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return loadingdialog;
    });
  }

  static void showAlertDialog(BuildContext context,String title,String content){
    AlertDialog alertdialog=AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text("OK"),)
      ],
    );
    showDialog(context: context, builder: (context){
      return alertdialog;
    });
  }
}