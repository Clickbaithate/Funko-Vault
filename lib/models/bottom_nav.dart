// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/screens/folder.dart';
import 'package:temp/screens/home.dart';
import 'package:temp/screens/liked.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  int currentPage = 1;
  List<Widget> pages = [FolderPage(), HomePage(), LikedPage()];

  void changePage(int pageNum) {
    setState(() {
      currentPage = pageNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentPage],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          margin: EdgeInsets.fromLTRB(48, 0, 48, 36),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: primaryColor, width: 4),
            borderRadius: BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                offset: Offset(0, 20),
                blurRadius: 20
              )
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // FOLDER NAV BUTTON
              GestureDetector(
                onTap: () {
                  changePage(0);
                },
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: currentPage == 0 ? primaryColor : backgroundColor
                  ),
                  child: Icon(
                    size: 36,
                    Icons.folder,
                    color: currentPage == 0 ? biegeColor : primaryColor,
                  ),
                ),
              ),
              // HOME NAV BUTTON 
              GestureDetector(
                onTap: () {
                  changePage(1);
                },
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: currentPage == 1 ? primaryColor : backgroundColor
                  ),
                  child: Icon(
                    size: 36,
                    Icons.home,
                    color: currentPage == 1 ? blueColor : primaryColor,
                  )
                ),
              ),
              // LIKED NAV BUTTON
              GestureDetector(
                onTap: () {
                  changePage(2);
                },
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: currentPage == 2 ? primaryColor : backgroundColor
                  ),
                  child: Icon(
                    size: 36,
                    Icons.favorite,
                    color: currentPage == 2 ? redColor : primaryColor,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}