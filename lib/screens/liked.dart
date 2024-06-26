// ignore_for_file: avoid_print, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:temp/components/funko_card.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/data/series.dart';
import 'package:temp/models/funko_model.dart';
import 'package:temp/services/database.dart';

class LikedPage extends StatefulWidget {
  const LikedPage({super.key});

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {

  List<String> series = seriesList;
  List<String> filters = [];
  List<Funko> allFunkos = [];
  List<Funko> filteredFunkos = [];
  TextEditingController searchController = TextEditingController();
  List<Color> pillColors = List.generate(seriesList.length, (index) => primaryColor);
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    fetchLikedFunkos();
  }

  void changeColor(int index, String filter) {
    setState(() {
      pillColors[index] = pillColors[index] == primaryColor ? blueColor : primaryColor;
      if (!filters.contains(filter)) {
        filters.add(filter);
      } else {
        filters.removeWhere((item) => item == filter);
      }
      filterFunkos();
    });
  }

  void filterFunkos() {
    setState(() {
      String searchQuery = searchController.text.toLowerCase();
      if (filters.isEmpty && searchQuery.isEmpty) {
        filteredFunkos = List.from(allFunkos);
      } else {
        filteredFunkos = allFunkos.where((funko) {
          List<String> funkoSeries = funko.series.split(',').map((s) => s.trim()).toList();
          bool matchesFilters = filters.every((filter) => funkoSeries.contains(filter));
          bool matchesSearch = funko.name.toLowerCase().contains(searchQuery);
          return matchesFilters && matchesSearch;
        }).toList();
      }
    });
  }

  Future<void> fetchLikedFunkos() async {
    try {
      List<Funko> likedFunkos = await _databaseService.getLikedFunkos();
      setState(() {
        allFunkos = likedFunkos;
        filteredFunkos = List.from(allFunkos);
      });
    } catch (e) {
      print("Error fetching liked Funkos: $e");
    }
  }

  void handleLiked() {
    fetchLikedFunkos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(225),
        child: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
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
          flexibleSpace: Column(
            children: [
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterFunkos();
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: primaryColor
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(index == 0 ? 16 : 2, 8, 4, 4),
                      child: GestureDetector(
                        onTap: () => changeColor(index, series[index]),
                        child: Container(
                          width: 130,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(color: pillColors[index], width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text(series[index]))
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Liked Funkos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ),
              )
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
              return FunkoCard(funko: filteredFunkos[index], onLiked: handleLiked);
            },
          ),
    );
  }
}