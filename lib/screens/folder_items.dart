import 'package:flutter/material.dart';
import 'package:temp/models/folder_model.dart';

class FolderItems extends StatefulWidget {

  final Folder folder;
  const FolderItems({ required this.folder, super.key });

  @override
  State<FolderItems> createState() => _FolderItemsState();
}

class _FolderItemsState extends State<FolderItems> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}