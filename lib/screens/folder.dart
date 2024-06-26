// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:temp/components/folder_card.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/models/folder_model.dart';
import 'package:temp/services/database.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {

  List<String> filters = [];
  List<Folder> allCollections = [];
  List<Folder> filteredCollections = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController collectionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    getCollections();
  }

  void filterCollections() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredCollections = List.from(allCollections);
      } else {
        filteredCollections = allCollections.where((collection) {
          bool matchesSearch = collection.name.toLowerCase().contains(searchQuery);
          return matchesSearch;
        }).toList();
      }
    });
  }

  void getCollections() async {
    try {
      List<Folder> collections = await _databaseService.getFolders();
      setState(() {
        allCollections = collections;
        filteredCollections = List.from(allCollections);
      });
    } catch (e) {
      print("Error fetching collections: $e");
    }
    print(filteredCollections.length);
  }

  void handleDelete() {
    getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          title: Center(
            child: Text(
              "FunkoVault",
              style: TextStyle(
                color: secondaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          scrolledUnderElevation: 0,
          backgroundColor: backgroundColor,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        print("New Collection!");
                        String? collectionName = await openDialog(context, collectionController);
                        if (collectionName != null && collectionName.isNotEmpty) {
                          await _databaseService.addFolder(collectionName);
                          getCollections();
                        }
                      },
                      icon: Icon(Icons.add, color: blueColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterCollections();
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Collections",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredCollections.isEmpty
          ? Center(child: Text("No Collections Found!"))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: filteredCollections.length,
              itemBuilder: (context, index) {
                return FolderCard(folder: filteredCollections[index], onDelete: handleDelete);
              },
            ),
    );
  }
}

Future<String?> openDialog(BuildContext context, TextEditingController collectionController) => showDialog<String>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text("Collection Name..."),
    content: TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Enter The Name of Your Collection..."
      ),
      controller: collectionController,
    ),
    actions: [
      TextButton(
        child: Text("SUBMIT"),
        onPressed: () {
          submit(context, collectionController);
          collectionController.clear();
        }
      )
    ],
  )
);

void submit(BuildContext context, TextEditingController collectionController) {
  Navigator.of(context).pop(collectionController.text);
}