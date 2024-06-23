// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temp/data/colors.dart';
import 'package:temp/models/folder_model.dart';
import 'package:temp/models/funko_model.dart';
import 'package:temp/services/database.dart';

class FunkoCard extends StatefulWidget {
  final Funko funko;
  final VoidCallback onLiked;
  final VoidCallback? onCollectionDelete;
  const FunkoCard({ this.onCollectionDelete, required this.onLiked, required this.funko, super.key});

  @override
  State<FunkoCard> createState() => _FunkoCardState();
}

class _FunkoCardState extends State<FunkoCard> {

  late bool isLiked;
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Folder> folders = [];

  Future<void> checkLikedStatus() async {
    bool liked = await _databaseService.isLiked(widget.funko);
    setState(() {
      isLiked = liked;
    });
  }

  Future<void> fetchFolders() async {
    List<Folder> fetchedFolders = await _databaseService.getFolders();
    setState(() {
      folders = fetchedFolders;
    });
  }

  @override
  void initState() {
    super.initState();
    isLiked = false;
    checkLikedStatus();
    fetchFolders();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Fluttertoast.showToast(
          msg: "Funko Name: ${widget.funko.name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: primaryColor,
          textColor: Colors.black,
          fontSize: 16,
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.funko.image,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            // Rating
            Positioned(
              top: 15,
              left: 12,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.33),
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text( 
                    widget.funko.series != '' ? "Series: ${widget.funko.series}"
                    : widget.funko.rating != '' ? "Rating: ${widget.funko.rating} / 5"
                    : widget.funko.scale != '' ? "Scale: ${widget.funko.scale}"
                    : widget.funko.type != '' ? "Type: ${widget.funko.type}"
                    : "Brand: ${widget.funko.brand}",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // Name
            Positioned(
              bottom: 15,
              left: 12,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.33),
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    widget.funko.name,
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // Like
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: const Color.fromARGB(255, 255, 0, 0)),
                onPressed: () async {
                  setState(() {
                    isLiked = !isLiked;
                  });
                  if (isLiked) {
                    await _databaseService.likeFunko(widget.funko);
                  } else {
                    await _databaseService.unlikeFunko(widget.funko.id);
                  }
                  widget.onLiked();
                },
              ),
            ),
            // Collection
            Positioned(
              top: 40,
              right: 8,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.folder, color: biegeColor),
                onSelected: (value) async {
                  // Check if the Funko Pop is already in the collection
                  bool isInCollection = await _databaseService.inFolder(value, widget.funko);

                  if (isInCollection) {
                    // Funko Pop is already in the collection, delete it
                    await _databaseService.deleteFromFolder(value, widget.funko.image);
                  } else {
                    // Funko Pop is not in the collection, add it
                    await _databaseService.addToFolder(value, widget.funko);
                  }

                  // Refresh the collections list
                  fetchFolders();
                  widget.onCollectionDelete!();
                },
                itemBuilder: (context) => folders.map((collection) {
                  return PopupMenuItem<String>(
                    value: collection.name,
                    child: Text(collection.name),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}