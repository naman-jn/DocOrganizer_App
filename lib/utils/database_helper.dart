import 'package:document_organizer/models/file.dart';
import 'package:document_organizer/models/tag.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper {

  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
  static Database _database;                // Singleton Database

  String fileTable = 'file_table';
  String colId = 'id';
  String colName = 'name';
  String colPath = 'path';
  String colSize = 'size';
  String colDate = 'date';
  String colType = 'type';
  String colFav ='fav';

  String tagTable = 'tag_table';
  String colIdTag = 'id';
  String colNameTag = 'name';
  String colFileIds='fileIds';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'files.db';

    // Open/create the database at a given path
    var filesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return filesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $fileTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT UNIQUE, '
        '$colPath TEXT, $colSize TEXT, $colDate TEXT, $colType TEXT, $colFav INTEGER)');
    await db.execute('CREATE TABLE $tagTable($colIdTag INTEGER PRIMARY KEY AUTOINCREMENT, $colNameTag TEXT UNIQUE, '
        '$colFileIds TEXT)');
  }

  // Fetch Operation: Get all file objects from database
  Future<List<Map<String, dynamic>>> getFileDMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $fileTable order by $colSize ASC');
    var result = await db.query(fileTable, orderBy: '$colSize DESC');
    return result;
  }

  //Insert Operation: Insert a FileD object to database
  Future<int> insertFileD(FileD file) async {
    Database db = await this.database;
    var result = await db.insert(fileTable, file.toMap());
    return result;
  }

  // Update Operation: Update a FileD object and save it to database
  Future<int> updateFileD(FileD file) async {
    var db = await this.database;
    var result = await db.update(fileTable, file.toMap(), where: '$colId = ?', whereArgs: [file.id]);
    return result;
  }

  // Delete Operation: Delete a FileD object from database
  Future<int> deleteFileD(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $fileTable WHERE $colId = $id');
    return result;
  }

  // Get number of FileD objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $fileTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'FileD List' [ List<FileD> ]
  Future<List<FileD>> getFileDList() async {

    var fileMapList = await getFileDMapList(); // Get 'Map List' from database
    int count = fileMapList.length;         // Count the number of map entries in db table

    List<FileD> fileList = List<FileD>();
    // For loop to create a 'FileD List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      fileList.add(FileD.fromMapObject(fileMapList[i]));
    }

    return fileList;
  }

  Future<List<Map<String, dynamic>>> getTagMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $tagTable order by $colSize ASC');
    var result = await db.query(tagTable, orderBy: '$colNameTag ASC');
    return result;
  }

//Insert Operation: Insert a Tag object to database
  Future<int> insertTag(Tag tag) async {
    Database db = await this.database;
    var result = await db.insert(tagTable, tag.toMap());
    return result;
  }

// Update Operation: Update a Tag object and save it to database
  Future<int> updateTag(Tag tag) async {
    var db = await this.database;
    var result = await db.update(tagTable, tag.toMap(), where: '$colIdTag = ?', whereArgs: [tag.id]);
    return result;
  }

// Delete Operation: Delete a Tag object from database
  Future<int> deleteTag(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tagTable WHERE $colIdTag = $id');
    return result;
  }

// Get number of Tag objects in database
  Future<int> getCountTag() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tagTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

// Get the 'Map List' [ List<Map> ] and convert it to 'Tag List' [ List<Tag> ]
  Future<List<Tag>> getTagList() async {

    var tagMapList = await getTagMapList(); // Get 'Map List' from database
    int count = tagMapList.length;         // Count the number of map entries in db table

    List<Tag> tagList = List<Tag>();
    // For loop to create a 'Tag List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tagList.add(Tag.fromMapObject(tagMapList[i]));
    }

    return tagList;
  }

 }





