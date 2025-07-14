import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagram/Widgets/uihelper.dart';

import '../Login/loginScreen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Container(
             child: Image.asset( "assets/images/instagram.png"),
             width: 100,
             height: 100,
           ),
            SizedBox(
              height: 20,
            ),
            UiHelper.CustomImage(imgurl: "logo.png")

          ],
        ),
      ),
    );
  }
}