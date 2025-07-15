
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/ViewUserProfile/viewuserprofileScreen.dart';

class SearchScreen extends StatefulWidget{
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];

  @override
  void initState() {

    super.initState();
    fetchAllUsers();
  }
  void fetchAllUsers() async{
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .get();
    setState(() {
      allUsers = snapshot.docs;
      // filteredUsers = allUsers;
    });
  }
  void searchUsers(String query){
    final results = allUsers.where((user){
      String username = user['username'].toLowerCase();
      return username.contains(query.toLowerCase());
    }).toList();

   setState(() {
     filteredUsers = results;
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              onChanged: searchUsers,
            ),
          ),
          Expanded(
              child: filteredUsers.isEmpty ?
          Center(child: Text("No users found"),):
                  ListView.builder(itemCount: filteredUsers.length,
                      itemBuilder: (context,index){
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage:
                        user['profilePic'] != null?
                            NetworkImage( user['profilePic']):
                        AssetImage("assets/images/user (1).png") as ImageProvider,
                        ),
                      title: Text(user['username']),
                      subtitle: Text(user['email']),
                      onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ViewUserProfileScreen(uid: user.id)));
                      },
                    );
                      })
          )
        ],
      )
    );
  }
}