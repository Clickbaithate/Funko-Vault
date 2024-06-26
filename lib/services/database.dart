import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:temp/models/folder_model.dart';
import 'package:temp/models/funko_model.dart';

class DatabaseService {

  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  // Creating and Initializing Database
  Future<Database> getDatabase() async {

    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "FunkoPops.db");

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
            CREATE TABLE liked (
              Id INTEGER PRIMARY KEY,
              Name TEXT,
              Series TEXT,
              Rating TEXT, 
              Scale TEXT,
              Brand TEXT,
              Type TEXT,
              Image TEXT UNIQUE
            );
          '''
        );
        await db.execute(
          '''
            CREATE TABLE folders (
              Id INTEGER PRIMARY KEY,
              Name TEXT UNIQUE
            );
          '''
        );
        await db.execute(
          '''
            CREATE TABLE folder_items (
              Id INTEGER PRIMARY KEY,
              FName TEXT,
              Name TEXT,
              Series TEXT,
              Rating TEXT, 
              Scale TEXT,
              Brand TEXT,
              Type TEXT,
              Image TEXT UNIQUE,
              FOREIGN KEY (FName) REFERENCES folders(Name)
            );
          '''
        );
      },
    );
    return database;
  }

  // check if a funko is "liked" (exists in the liked table)
  Future<bool> isLiked(Funko funko) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      "liked",
      where: "Id = ?",
      whereArgs: [funko.id]
    );
    return results.isNotEmpty;
  }

  // given a folder, check if the funko is in that folder
  Future<bool> inFolder(String folderName, Funko funko) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      "folder_items",
      where: 'FName = ? AND Image = ?',
      whereArgs: [folderName, funko.image],
    );
    return result.isNotEmpty;
  }

  // likes a funko AKA stores the funko in the liked table
  Future<void> likeFunko(Funko funko) async {
    final db = await database;
    await db.insert(
      "liked",
      {
        "Id": funko.id,
        "Name": funko.name,
        "Series": funko.series,
        "Rating": funko.rating,
        "Scale": funko.scale,
        "Brand": funko.brand,
        "Type": funko.type,
        "Image": funko.image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // add a new folder
  Future<void> addFolder(String name) async {
    final db = await database;
    await db.insert(
      "folders",
      {
        "Name": name
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Unlike a Funko Pop AKA delete the funko from the liked table
  Future<void> unlikeFunko(int id) async {
    final db = await database;
    await db.delete(
      'liked',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  // delete folder and all funkos in that folder
  Future<void> deleteFolder(int id) async {

    final db = await database;

    final folder = await db.query(
      "folders",
      where: 'Id = ?',
      whereArgs: [id],
    );

    // Delete the folder from the folders table
    await db.delete(
      "folders",
      where: 'Id = ?',
      whereArgs: [id],
    );

    // Delete all folder items associated with the folder
    await db.delete(
      "folder_items",
      where: 'FName = ?',
      whereArgs: [folder.first["Name"] as String],
    );

  }

  // deleting a funko that belongs to a specific folder
  Future<void> deleteFromFolder(String name, String image) async {
    final db = await database;
    await db.delete(
      "folder_items",
      where: 'FName = ? AND image = ?',
      whereArgs: [name, image]
    );
  }

  // get all funkos from the liked table
  Future<List<Funko>> getLikedFunkos() async {
    final db = await database;
    final data = await db.query("liked");
    List<Funko> likedFunkos = data.map(
      (e) => Funko(
        id: e["Id"] as int,
        name: e["Name"] as String,
        series: e["Series"] as String,
        rating: e["Rating"] as String,
        scale: e["Scale"] as String,
        brand: e["Brand"] as String,
        type: e["Type"] as String,
        image: e["Image"] as String,
      ),
    ).toList();
    return likedFunkos;
  }

  // get all the folders
  Future<List<Folder>> getFolders() async {
    final db = await database;
    final data = await db.query("folders");
    List<Folder> folders = data.map(
      (e) => Folder(
        id: e["Id"] as int, 
        name: e["Name"] as String
      ),
    ).toList();
    return folders;
  }

  // get all funkos from a specific folder
  Future<List<Funko>> getSavedFunkos(String folderName) async {
    final db = await database;
    final data = await db.query(
      "folder_items",
      where: 'FName = ?',
      whereArgs: [folderName],
    );
    List<Funko> funkos = data.map(
      (e) => Funko(
        id: e["Id"] as int,
        name: e["Name"] as String,
        series: e["Series"] as String,
        rating: e["Rating"] as String,
        scale: e["Scale"] as String,
        brand: e["Brand"] as String,
        type: e["Type"] as String,
        image: e["Image"] as String,
      ),
    ).toList();
    return funkos;
  }

  // add a funko to a specific folder
  Future<void> addToFolder(String folderName, Funko funko) async {
    final db = await database;
    await db.insert(
      "folder_items",
      {
        "FName": folderName,
        "Name": funko.name,
        "Series": funko.series,
        "Rating": funko.rating,
        "Scale": funko.scale,
        "Brand": funko.brand,
        "Type": funko.type,
        "Image": funko.image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
