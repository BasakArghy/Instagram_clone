
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/Screens/Heart/heartScreen.dart';
import 'package:instagram/Screens/Home/homeScreen.dart';
import 'package:instagram/Screens/Post/postScreen.dart';
import 'package:instagram/Screens/profile/profileScreen.dart';
import 'package:instagram/Screens/search/searchScreen.dart';
import 'package:instagram/Widgets/uihelper.dart';

class BottomNavScreen extends StatefulWidget{
  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    homeScreen(),
  SearchScreen(),
    PostScreen(),
    HeartScreen(),
    ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: TextStyle(color: Colors.grey),
          backgroundColor: Colors.black,
          onTap: (index){
            setState(() {
              currentIndex = index;
            });

          },
          items: [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search),label: "Search"),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_app),label: "Post"),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart),label: "Heart"),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled),label: "Profile"),
      ]),
      body: IndexedStack(
        children: pages,
        index: currentIndex,
      ),
    );
  }
}