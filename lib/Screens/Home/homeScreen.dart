import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/Home/commentScreen.dart';
import 'package:instagram/Screens/Login/loginScreen.dart';
import 'package:instagram/Screens/Messenger/chathomeScreen.dart';
import 'package:instagram/Widgets/uihelper.dart';
import 'package:intl/intl.dart';

class homeScreen extends StatelessWidget{
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    String displayName = user?.displayName ?? "user";
  return Scaffold(
    appBar: AppBar(
      title: Text("Instagram"),
      actions: [
        IconButton(
            onPressed: ()async{

              Navigator.push(context,  MaterialPageRoute(builder: (context)=>ChatHomeScreen()));
            },
            icon: Icon(CupertinoIcons.chat_bubble_fill)),
        IconButton(
            onPressed: ()async{
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context)=>LoginScreen()));
            },
            icon: Icon(Icons.logout)),

      ],
    ),
    body: StreamBuilder(
        stream: FirebaseFirestore.instance
        .collection("posts")
        .orderBy("createdAt",descending: true)
        .snapshots(),
        builder: (context,snapshot) {
          if(snapshot.hasError){
            return Center(child: Text("Error loading posts"),);
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          final posts = snapshot.data!.docs;
          if(posts.isEmpty){
            return Center(child: Text("No posts yet."),);
          }
          return ListView.builder(
            itemCount: posts.length,
              itemBuilder: (context,index){
              var post = posts[index];
              String caption = post['caption'];
              String uname = post['uname'];
              String imageUrl = post['imageUrl'];
              Timestamp timestamp = post['createdAt'];
              String data = DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());

              return Card(
                margin: EdgeInsets.all(8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.profile_circled),
                          SizedBox(width: 5,),
                          Text(uname,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                        ],
                      ),
                    ),
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
                    Row(
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
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(caption,style: TextStyle(fontSize: 16),),
                          SizedBox(height: 5,),
                          Text(data,style: TextStyle(fontSize: 12,color: Colors.grey),)
                        ],
                      ),
                    ),
                ],),
              );

            }
          );
        })
  );
  }

}
