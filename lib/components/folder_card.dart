// ignore_for_file: prefer_const_constructors
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/data/folder_colors.dart';
import 'package:temp/models/folder_model.dart';
import 'package:temp/screens/folder_items.dart';
import 'package:temp/services/database.dart';

class FolderCard extends StatefulWidget {
  final Folder folder;
  final VoidCallback onDelete;
  const FolderCard({ required this.folder, required this.onDelete, super.key });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {

  final DatabaseService _databaseService = DatabaseService.instance;
  var randomColor = colorsList[Random().nextInt(14)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Fluttertoast.showToast(
          msg: "Folder Name: ${widget.folder.name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: primaryColor,
          textColor: Colors.black,
          fontSize: 16
        );
      },
      // Takes user to a dedicated folder page that shows them all the funkos under that folder
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderItems(folder: widget.folder)
          ),
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // background color of folder card
              Positioned.fill(
                child: Container(color: randomColor),
              ),
              // name bubble of folder card
              Positioned(
                bottom: 15,
                left: 12,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.33),
                  decoration: BoxDecoration(color: randomColor, borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      widget.folder.name,
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ),
              ),
              // Delete Icon of folder card
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Color.fromARGB(255, 70, 70, 70)),
                  onPressed: () async {
                    await _databaseService.deleteFolder(widget.folder.id);
                    widget.onDelete();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}