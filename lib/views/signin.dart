import 'package:chatter_app/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text("Messenger Clone",style: TextStyle(
          color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.w600
        ),),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: (){
            AuthMethods().signInWithGoogle(context);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(24)
            ),
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
            child: Text("sign in with google",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white
            ),
            ),),
        ),),
    );
  }
}
