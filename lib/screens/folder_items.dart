// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:temp/components/funko_card.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/models/folder_model.dart';
import 'package:temp/models/funko_model.dart';
import 'package:temp/services/database.dart';

class FolderItems extends StatefulWidget {

  final Folder folder;
  const FolderItems({ required this.folder, super.key });

  @override
  State<FolderItems> createState() => _FolderItemsState();
}

class _FolderItemsState extends State<FolderItems> {

  List<Funko> allFunkos = [];
  List<Funko> filteredFunkos = [];
  TextEditingController searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    fetchCollectedFunkos();
  }

  void filterCollections() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredFunkos = List.from(allFunkos);
      } else {
        filteredFunkos = allFunkos.where((collection) {
          bool matchesSearch = collection.name.toLowerCase().contains(searchQuery);
          return matchesSearch;
        }).toList();
      }
    });
  }

  Future<void> fetchCollectedFunkos() async {
    try {
      List<Funko> collectedFunkos = await _databaseService.getSavedFunkos(widget.folder.name);
      print("Funko Collected: ${widget.folder.name}");
      setState(() {
        allFunkos = collectedFunkos;
        filteredFunkos = List.from(allFunkos);
      });
    } catch (e) {
      print("Error fetching liked Funkos: $e");
    }
  }

  void handleLiked() {
    fetchCollectedFunkos();
  }

  void handleDeleted() {
    fetchCollectedFunkos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          title: Text(
              "Collections",
              style: TextStyle(
                color: secondaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          scrolledUnderElevation: 0,
          backgroundColor: backgroundColor,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    widget.folder.name,
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
      body: filteredFunkos.isEmpty
        ? Center(child: Text("No liked Funkos found!"))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: filteredFunkos.length,
            itemBuilder: (context, index) {
              return FunkoCard(funko: filteredFunkos[index], onLiked: handleLiked, onCollectionDelete: handleDeleted);
            },
          ),
    );
  }
}