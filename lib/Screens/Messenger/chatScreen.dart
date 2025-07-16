import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String othername;

  const ChatScreen({super.key, required this.otherUserId,required this.othername});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController _messageController = TextEditingController();

  String getChatId(String uid1, String uid2) {
    //return [uid1,uid2].sort(); // Sort to keep consistent chatId
    return uid1.compareTo(uid2) < 0 ? "$uid1\_$uid2" : "$uid2\_$uid1";
  }

  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatId = getChatId(currentUser.uid, widget.otherUserId);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Add message
    await chatRef.collection('messages').add({
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    // Update last message
    await chatRef.set({
      'participants': [currentUser.uid, widget.otherUserId],
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(currentUser.uid, widget.otherUserId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.othername)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white12
              ),
              child: Row(

                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration:
                      InputDecoration(hintText: "Type a message...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: sendMessage,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
