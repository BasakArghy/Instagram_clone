import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/Messenger/SearchUserToChatScreen.dart';
import 'chatScreen.dart';

class ChatHomeScreen extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getChatListStream() {
    return FirebaseFirestore.instance
        .collection("chats")
        .where("participants", arrayContains: currentUserId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchUserToChatScreen()),
              );
            },
            child: Container(
              color: Colors.white12,
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.search, size: 30),
                  SizedBox(width: 8),
                  Text("Start new chat", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getChatListStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text("No chats yet"));

                final chats = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final data = chat.data() as Map<String, dynamic>;

                    final lastMessage = data['lastMessage'] ?? '';
                    final lastTime = data['lastMessageTime'];
                    final participants =
                    List<String>.from(data['participants'] ?? []);

                    if (!participants.contains(currentUserId)) {
                      return SizedBox();
                    }

                    final otherUserId = participants.firstWhere(
                            (id) => id != currentUserId,
                        orElse: () => '');

                    if (otherUserId.isEmpty) return SizedBox();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(otherUserId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData)
                          return ListTile(title: Text("Loading..."));

                        final userData = userSnapshot.data!.data()
                        as Map<String, dynamic>?;

                        if (userData == null) return SizedBox();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userData['profilePic'] != null &&
                                userData['profilePic'].toString().isNotEmpty
                                ? NetworkImage(userData['profilePic'])
                                : AssetImage("assets/images/user (1).png")
                            as ImageProvider,
                          ),
                          title: Text(userData['username'] ?? "User"),
                          subtitle: Text(lastMessage),
                          trailing: lastTime != null
                              ? Text(
                            TimeOfDay.fromDateTime(
                                lastTime.toDate())
                                .format(context),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                    otherUserId: otherUserId,
                                othername: userData['username']),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
