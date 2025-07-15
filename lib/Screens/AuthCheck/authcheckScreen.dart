import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/Screens/Home/homeScreen.dart';
import 'package:instagram/Screens/Login/loginScreen.dart';
import 'package:instagram/Screens/bottomnav/bottomnav.dart';

class authcheck extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      return BottomNavScreen();
    }
    else{
      return LoginScreen();
    }
  }

}