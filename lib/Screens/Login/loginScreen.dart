

import 'package:flutter/material.dart';
import 'package:instagram/Widgets/uihelper.dart';

import '../SignUp/signupScreen.dart';


class LoginScreen extends StatelessWidget{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {

   return Scaffold(
    /* appBar: AppBar(
       title: Text("Login Screen"),
       centerTitle: true,
       backgroundColor: Colors.blue,
     ),*/
     body:Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
         UiHelper.CustomImage(imgurl: "logo.png"),
          SizedBox(height: 20),
           UiHelper.CustomTextField(controller: emailController, text: "Email", tohide: false, textinputtype: TextInputType.text),
           SizedBox(height: 15),
           UiHelper.CustomTextField(controller: passwordController, text: "Password", tohide: true, textinputtype: TextInputType.visiblePassword),
           Row(mainAxisAlignment: MainAxisAlignment.end,
             children: [
             Padding(padding: const EdgeInsets.only(right: 20),
             child:  UiHelper.CustomTextButton(callback: (){}, text: "Forgot password?"),)
           ],),
            SizedBox(height: 10,),
           UiHelper.CustomButton(callback: (){}, buttonName: "Login"),
           SizedBox(height: 20,),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
             UiHelper.CustomImage(imgurl: "fbicon.png"),
             UiHelper.CustomTextButton(callback: (){}, text: "Log in with Facebook")
           ],),
           SizedBox(height: 10,),
           Text("OR",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
           SizedBox(height: 10,),
           Row(mainAxisAlignment: MainAxisAlignment.center,
             children: [
             Text("Don't have an account?",style: TextStyle(fontSize: 14,color: Colors.white54),),
             UiHelper.CustomTextButton(callback: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));}, text: "Sign Up")
           ],)
       ],),
     ) ,
   );
  }
}