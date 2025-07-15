
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/EditProfile/editprofileScreen.dart';
import 'package:instagram/Widgets/uihelper.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget{

  Future<DocumentSnapshot> getUserData() async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  Stream<QuerySnapshot> getUserPosts(){
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("posts")
        .where("uid",isEqualTo: uid)
        .orderBy("createdAt",descending: true)
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
          builder: (context,userSnapshot){
            if(userSnapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            if(!userSnapshot.hasData || !userSnapshot.data!.exists){
              return Center(child: Text("User data not found."),);
            }
            final userData = userSnapshot.data!.data() as Map<String,dynamic>;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),

                 CircleAvatar(
                  radius: 45,
                  backgroundImage: userData['profilePic'] != null && userData['profilePic'].toString().isNotEmpty
                      ? NetworkImage(userData['profilePic'])
                      : AssetImage("assets/images/user (1).png") as ImageProvider
                ),


                  SizedBox(height: 10,),
                  Text(userData['username'] ?? "",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  Text(userData['email'] ?? "",style: TextStyle(color: Colors.grey),),
                  SizedBox(height: 20,),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                    },
                    child: Text("Edit Profile"),
                  ),

                  Divider(thickness: 1,),
                  Text("Your Posts",style: TextStyle(fontSize: 16),),
                   StreamBuilder(
                          stream: getUserPosts(),
                          builder: (context,postSnapshot){
              
                            if(postSnapshot.connectionState == ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator(),);
                            }
                            if (!postSnapshot.hasData || postSnapshot.data == null) {
                              return Center(child: Text("No data found."));
                            }
                            final posts = postSnapshot.data!.docs;
                            if(posts.isEmpty){
                              return Center(child: Text("You haven't posted yet."),);
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                                itemBuilder: (context,index){
              
                                  final post = posts[index];
                                  String imageUrl = post['imageUrl'];
                                  String caption = post['caption'];
                                  String date = DateFormat('MMM dd, yyyy – hh:mm a')
                                      .format(post['createdAt'].toDate());
                                  return Card(
                                    margin: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context,child,loadingProgress){
                                            if(loadingProgress==null) return child;
                                            return Container(
                                              height: 200,
                                              child: Center(child: CircularProgressIndicator(),),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(caption),
                                              SizedBox(height: 5),
                                              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
              
              
                                });
                          })
                ],
              
              ),
            );
          }
      )
    );
  }

}