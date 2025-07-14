import 'package:flutter/material.dart';
import 'package:instagram/Screens/Login/loginScreen.dart';
import 'package:instagram/Widgets/uihelper.dart';

class SignUpScreen extends StatelessWidget{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
        UiHelper.CustomImage(imgurl: "logo.png"),
          SizedBox(height: 20),
          UiHelper.CustomTextField(controller: emailController, text: "Email", tohide: false, textinputtype: TextInputType.text),
          SizedBox(height: 15),
          UiHelper.CustomTextField(controller: passwordController, text: "Password", tohide: true, textinputtype: TextInputType.visiblePassword),
          SizedBox(height: 15),
          UiHelper.CustomTextField(controller: userNameController, text: "Username", tohide: false, textinputtype: TextInputType.text),
          SizedBox(height: 20),
          UiHelper.CustomButton(callback: (){}, buttonName: "Sign Up"),
          SizedBox(height: 25,),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an Account?",style: TextStyle(fontSize: 14,color: Colors.white54),),
              UiHelper.CustomTextButton(callback: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));}, text: "Sign In")
            ],)
      ],),
    ),
   );
  }

}