
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/EditProfile/editprofileScreen.dart';
import 'package:instagram/Screens/Home/commentScreen.dart';
import 'package:instagram/Widgets/uihelper.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget{
  final User? user = FirebaseAuth.instance.currentUser;

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
                                        ),      Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                post['likes'] != null && post['likes'].contains(user!.uid)
                                                    ?Icons.favorite
                                                    : Icons.favorite_border,
                                                color:post['likes'] != null && post['likes'].contains(user!.uid)
                                                    ?Colors.red
                                                    :Colors.grey,
                                              ),
                                              onPressed:()async{
                                                final postRef = FirebaseFirestore.instance
                                                    .collection("posts")
                                                    .doc(post.id);
                                                final likes = List<String>.from(post["likes"]??[]);
                                                if(likes.contains(user!.uid)){
                                                  //unlike
                                                  await postRef.update({
                                                    "likes":FieldValue.arrayRemove([user!.uid])
                                                  });
                                                }
                                                else{
                                                  await postRef.update({
                                                    "likes": FieldValue.arrayUnion([user!.uid])
                                                  });
                                                }

                                              },

                                            ),
                                            Text('${(post['likes'] ?? []).length}'),
                                            IconButton(onPressed: (){
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) => CommentScreen(postId: post.id),
                                              );

                                            },
                                                icon: Icon(Icons.comment_outlined)
                                            ),
                                            Spacer(),
                                            // 🗑️ Delete button
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () async {
                                                final confirm = await showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text("Delete Post"),
                                                    content: Text("Are you sure you want to delete this post?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: Text("Cancel"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: Text("Delete", style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  // Delete from Firestore
                                                  await FirebaseFirestore.instance.collection("posts").doc(post.id).delete();

                                                  // Delete from Cloudinary (optional)
                                                 /* if (post['publicId'] != null && post['publicId'].toString().isNotEmpty) {
                                                    await deleteFromCloudinary(post['publicId']);
                                                  }*/

                                                  UiHelper.showAlertDialog(context, "Deleted", "Post has been deleted.");
                                                }
                                              },)
                                          ],
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