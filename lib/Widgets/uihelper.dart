import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiHelper {


  static CustomTextField({required TextEditingController controller,
    required String text,
    required bool tohide,
    required TextInputType textinputtype}) {
    return Container(
      height: 50,
      width: 343,
      decoration: BoxDecoration(
          color: Color(0XFF121212),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: TextField(
          controller: controller,
          keyboardType: textinputtype,
          obscureText: tohide,
          decoration: InputDecoration(
              hintText: text,
              hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
              border: InputBorder.none),
        ),
      ),
    );
  }

  static CustomImage({required String imgurl}) {
    return Image.asset("assets/images/$imgurl");
  }

  static CustomTextButton(
      {required VoidCallback callback, required String text}) {
    return TextButton(onPressed: () {
      callback();
    },
        child: Text(text,style: TextStyle(color: Color(0XFF3797EF),fontSize: 14)));
  }
  static CustomButton({required VoidCallback callback,required String buttonName}){
    return SizedBox(
      height: 45,
      width: 343,
      child: ElevatedButton(onPressed: (){callback();},
          child: Center(
              child: Text(buttonName,style: TextStyle(color: Colors.white,fontSize: 14),)),
      style: ElevatedButton.styleFrom(backgroundColor: Color(0XFF3797EF),shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      )),),
    );
  }
  
  static void showAlertDialog(BuildContext context,String title,String message){
    showDialog(context: context,
        builder: (context)=>AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(context),
                child: Text("OK"))
          ],
        ));
  }
  

}
