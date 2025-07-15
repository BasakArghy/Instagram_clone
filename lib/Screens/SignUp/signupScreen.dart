import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/Home/homeScreen.dart';
import 'package:instagram/Screens/Login/loginScreen.dart';
import 'package:instagram/Screens/bottomnav/bottomnav.dart';
import 'package:instagram/Widgets/uihelper.dart';

class SignUpScreen extends StatelessWidget{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  void signUp(String email,String password,String username,BuildContext context) async{
    if(email.isEmpty ){
      UiHelper.showAlertDialog(context, "Error", "Please fill Email field.");
      return;
    }
    if(password.isEmpty ){
      UiHelper.showAlertDialog(context, "Error", "Please fill Email field.");
      return;
    }
    if(username.isEmpty ){
      UiHelper.showAlertDialog(context, "Error", "Please fill Email field.");
      return;
    }
    try{
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      //optionally ,update the display name
      await userCredential.user!.updateDisplayName(username);
      //Store user in Firestore
      await FirebaseFirestore.instance
      .collection("users")
      .doc(userCredential.user!.uid)
      .set({
        "uid":userCredential.user!.uid,
        "username":username,
        "email":email,
        "profilePic":"",
        "createdAt":FieldValue.serverTimestamp(),
      });

      UiHelper.showAlertDialog(context, "Success", "Account created!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomNavScreen()));
    } on FirebaseAuthException catch(e){
      UiHelper.showAlertDialog(context, "Signup Failed", e.message??"Unknown error");
    }
  }



  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
        UiHelper.CustomImage(imgurl: "logo.png"),
          SizedBox(height: 20),
          UiHelper.CustomTextField(controller: userNameController, text: "Username", tohide: false, textinputtype: TextInputType.text),
          SizedBox(height: 20),
          UiHelper.CustomTextField(controller: emailController, text: "Email", tohide: false, textinputtype: TextInputType.text),
          SizedBox(height: 15),
          UiHelper.CustomTextField(controller: passwordController, text: "Password", tohide: true, textinputtype: TextInputType.visiblePassword),
          SizedBox(height: 15),

          UiHelper.CustomButton(callback: (){
            String email = emailController.text.trim();
            String password = passwordController.text.trim();
            String username = userNameController.text.trim();
            signUp(email, password,username, context);
          }, buttonName: "Sign Up"),
          SizedBox(height: 20,),
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