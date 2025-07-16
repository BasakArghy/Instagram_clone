import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatScreen.dart';

class SearchUserToChatScreen extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Start a Chat")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userData['profilePic'] != null
                      ? NetworkImage(userData['profilePic'])
                      : AssetImage("assets/images/user (1).png") as ImageProvider,
                ),
                title: Text(userData['username']),
                subtitle: Text(userData['email'] ?? ''),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(otherUserId: user.id,othername:userData['username'] ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
