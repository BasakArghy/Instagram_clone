import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/Widgets/uihelper.dart';

class EditProfileScreen extends StatefulWidget{
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  File? _newProfileImage;
  bool isUploading = false;

  final picker = ImagePicker();
  //Cloudinary Config
  final  String cloudName = "dmtfgifky";
  final String uploadPreset = "instagram";

  Map<String,dynamic>? userData;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData()async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(doc.exists){
      setState(() {
        userData=  doc.data() as Map<String,dynamic>;
        usernameController.text= userData?['username'];
      });
    }

  }

  Future<void> pickNewImage()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }
  Future<String?> uploadToCloudinary(File file) async{
    String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";
    var request = http.MultipartRequest('POST',Uri.parse(uploadUrl));
    request.fields['upload_preset']=uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file',file.path));

    var response = await request.send();
    var resStream = await response.stream.bytesToString();
    if(response.statusCode==200){
      var data = jsonDecode(resStream);
      return data['secure_url'];
    }
    return null;
  }

  Future<void> updateProfile()async{
    setState(() {
      isUploading = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String newUsername = usernameController.text.trim();
    String? newImageUrl;

    try{
      if(_newProfileImage != null){
        newImageUrl = await uploadToCloudinary(_newProfileImage!);
      }
      Map<String,dynamic> updateData = {
        "username":newUsername,
      };
      if(newImageUrl != null){
        updateData["profilePic"]=newImageUrl;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update(updateData);

      Navigator.pop(context);
    } catch(e){

      UiHelper.showAlertDialog(context, "Error", e.toString());
    }
    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Edit Profile"),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(

          children: [
            GestureDetector(
              onTap: pickNewImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newProfileImage != null ?
                FileImage(_newProfileImage!):
                    userData?['profilePic'] != null?
                NetworkImage(userData?['profilePic']):
                    AssetImage("assets/images/user (1).png") as ImageProvider,
              ),
            ),
            SizedBox(height: 10,),
            Text("Tap to change profile picture"),
            SizedBox(height: 30,),
            UiHelper.CustomTextField(controller: usernameController, text: "", tohide:false, textinputtype: TextInputType.text),

            SizedBox(height: 20,),
            ElevatedButton(onPressed: isUploading ? null : updateProfile,
                child: isUploading
            ? CircularProgressIndicator()
                    : Text("Save Changes"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white12)
            )
          ],
        ),
      ),
    )
  );

  }
}