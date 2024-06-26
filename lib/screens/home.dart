// ignore_for_file: prefer_const_constructors, avoid_print, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:temp/components/funko_card.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/data/series.dart';
import 'package:http/http.dart' as http;
import 'package:temp/models/funko_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool dataFetched = false;
  List<String> series = seriesList;
  List<String> filters = [];
  List<Funko> allFunkos = [];
  List<Funko> filteredFunkos = [];
  TextEditingController searchController = TextEditingController();
  List<Color> pillColors = List.generate(seriesList.length, (index) => primaryColor);
  var client = http.Client();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 43001; i += 1000) {
      fetchFunkos(i);
    }
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
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

  Future<void> fetchFunkos(int offset) async {
    try {
      final url = "http://funkopop-api.onrender.com/funko?limit=1000&offset=$offset";
      final uri = Uri.parse(url);
      final response = await client.get(uri).timeout(Duration(seconds: 10));
      final body = response.body;
      final json = body.isNotEmpty ? jsonDecode(body) as List<dynamic> : null;

      if (mounted && json != null) {
        setState(() {
          for (var funko in json) {
            final funkoPop = Funko(
              id: funko["Id"],
              name: funko["Name"],
              series: funko["Series"],
              rating: funko["Rating"],
              scale: funko["Scale"],
              brand: funko["Brand"],
              type: funko["Type"],
              image: funko["Image"],
            );
            allFunkos.add(funkoPop);
          }
          filteredFunkos = List.from(allFunkos);
          dataFetched = true;
          print("Number of Funkos: ${allFunkos.length}");
        });
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  void handleLiked() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(225),
        child: AppBar(
          scrolledUnderElevation: 0,
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
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: primaryColor),
                    ))),
              ),
              SizedBox(height: 10),
              // Filter Pills
              Container(
                  height: 60,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              EdgeInsets.fromLTRB(index == 0 ? 16 : 2, 8, 4, 4),
                          child: GestureDetector(
                            onTap: () => changeColor(index, series[index]),
                            child: Container(
                              width: 130,
                              decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border.all(
                                      color: pillColors[index], width: 3),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(child: Text(series[index])),
                            ),
                          ),
                        );
                      })),
              // List Title
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Funko Collectibles",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              )
            ],
          ),
        ),
      ),
      body: dataFetched ? Container(
        color: backgroundColor,
        child: GridView.builder( 
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: filters.isEmpty ? filteredFunkos.length : filteredFunkos.length,
          itemBuilder: (context, index) {
            return FunkoCard(funko: filteredFunkos[index], onLiked: handleLiked);
          }
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}