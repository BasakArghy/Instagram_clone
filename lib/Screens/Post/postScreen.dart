
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/Widgets/uihelper.dart';

class PostScreen extends StatefulWidget{
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _imageFile;
  TextEditingController captionController = TextEditingController();
  bool isUploading = false;
  final picker = ImagePicker();

  //Cloudinary Config
  final  String cloudName = "dmtfgifky";
  final String uploadPreset = "instagram";

  Future<void> pickImage()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadToCloudinary(File imageFile)async{
    String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
    var request = http.MultipartRequest('POST',Uri.parse(uploadUrl));
    request.fields['upload_preset']=uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file',imageFile.path));

    var response = await request.send();
    var resStream = await response.stream.bytesToString();

    if(response.statusCode == 200){
      var data = jsonDecode(resStream);
      return data['secure_url'];
    }
    else{
      print("Cloudinary upload failed: ${response.statusCode}");
      return null;
    }

  }

  Future<void> uploadPost()async{
    if (_imageFile == null ){
      UiHelper.showAlertDialog(context, "Error", "Select an image");
      return;
    }
    if(captionController.text.trim().isEmpty){
      UiHelper.showAlertDialog(context, "Error", "Select a caption");
      return;
    }
    setState(() {
      isUploading= true;
    });
    try{
      //upload image to Cloudinary
      String? imageUrl = await uploadToCloudinary(_imageFile!);
      if(imageUrl == null){
        UiHelper.showAlertDialog(context, "Upload Failed", "Image upload failed.");
        setState(() {
          isUploading = false;
          return;
        });}
        String uid = FirebaseAuth.instance.currentUser!.uid;
        String? uname = FirebaseAuth.instance.currentUser!.displayName;
        await FirebaseFirestore.instance.collection("posts").add({
          "uid":uid,
          "uname":uname,
          "imageUrl":imageUrl,
          "caption":captionController.text.trim(),
          "likes":[],
          "createdAt": FieldValue.serverTimestamp()
        });

        UiHelper.showAlertDialog(context, "Success", "Post uploaded!");
        setState(() {
          _imageFile = null;
          captionController.clear();
          isUploading = false;
        });

    } catch(e){
      UiHelper.showAlertDialog(context, "Error", e.toString());
      setState(() => isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("New Post",style: TextStyle(fontSize: 17),),
       actions: [
         TextButton(onPressed: isUploading ? null : uploadPost,
             child: Text("Post",style: TextStyle(color: Colors.white,fontSize: 16),))
       ],
     ),
     body:SingleChildScrollView(
       padding: EdgeInsets.all(16),
       child: Column(
         children: [
           if(_imageFile != null)
             Image.file(_imageFile!,height: 250,width: double.infinity,fit: BoxFit.cover,)
          else
            GestureDetector(
             onTap: pickImage,
             child: Container(
               height: 250,
               width:double.infinity ,
               color: Colors.grey[300],
               child: Icon(Icons.add_a_photo,size: 50,),
             ),
           ),
           SizedBox(height: 20,),
           TextField(
             controller: captionController,
             maxLines: 3,
             decoration: InputDecoration(
               hintText: "Write a caption...",
               border: OutlineInputBorder()
             ),
           ),
           if (isUploading)...[
             SizedBox(height: 20,),
             CircularProgressIndicator()
           ]
         ],
       ),
     )
   );
  }
}