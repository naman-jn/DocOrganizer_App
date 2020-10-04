import 'dart:io';

import 'package:document_organizer/models/file.dart';
import 'package:document_organizer/models/tag.dart';
import 'package:document_organizer/screens/tags.dart';
import 'package:document_organizer/utils/consts.dart';
import 'package:document_organizer/utils/file_utils.dart';
import 'package:document_organizer/widgets/anim_bottom_bar.dart';
import 'package:document_organizer/utils/database_helper.dart';
import 'package:document_organizer/widgets/pick_file_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:upgrader/upgrader.dart';

class Home extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(
      text: "Home",
      iconData: Icons.home,
      color: Colors.blueAccent,
    ),
    BarItem(
      text: "Favourite",
      iconData: Icons.favorite_border,
      color: Colors.pink,
    ),
    BarItem(
      text: "Tags",
      iconData: Icons.bookmark_border,
      color: Colors.orangeAccent,
    ),
  ];

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static BuildContext alertContext;

  @override
  void initState() {
    createDir();
    super.initState();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showPushDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        showPushDialog(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showPushDialog(message);
      },
    );
  }

  final GlobalKey<TagsPageState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static TagsPageState tagsPageState = TagsPageState();

  final List<String> sortItems = ['Name', 'Date', 'Size'];
  static int sortIndex = 1;
  final List<String> sortBy = ['Ascending', 'Descending'];
  static int sortByIndex = 1;
  TextEditingController renameCtrl = TextEditingController();

  bool isProgressing = false;

  int sort = sortByIndex == 0 ? sortIndex : 3 + sortIndex;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<FileD> fileList;
  int count = 0;
  int selectedBarIndex = 0;
  List<FileD> allFiles;

  var _formKey = GlobalKey<FormState>();

  static var _filesTypes = [
    'All Documents',
    'PDF',
    'DOC',
    'PPT',
    'XLS',
    'TXT',
    'JPG'
  ];

  FileD file;

  @override
  Widget build(BuildContext context) {
    if (fileList == null) {
      fileList = List<FileD>();
      allFiles = fileList;
      updateListView();
    }
    alertContext = context;
    Constants.allFileList = allFiles;

    double initial, distance;
    return GestureDetector(
      onTap: () {
        if (Constants.isDrawerOpen == true) changeDrawer();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      onPanStart: (DragStartDetails details) {
        initial = details.globalPosition.dx;
      },
      onPanUpdate: (DragUpdateDetails details) {
        distance = details.globalPosition.dx - initial;
      },
      onPanEnd: (DragEndDetails details) {
        if (distance < 0 && selectedBarIndex < 2) selectedBarIndex++;
        if (distance > 0 && selectedBarIndex > 0) selectedBarIndex--;
        initial = 0.0;
        updateListView();
      },
      child: AnimatedContainer(
        transform:
            Matrix4.translationValues(Constants.xOffset, Constants.yOffset, 0)
              ..scale(Constants.scaleFactor),
        duration: Duration(milliseconds: 450),
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Constants.isDrawerOpen ? 45 : 0),
            boxShadow: [
              BoxShadow(
                spreadRadius: 5,
                color: Colors.black87,
                blurRadius: 45,
              ),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Constants.isDrawerOpen ? 30 : 0),
          child: Scaffold(
            key: _scaffoldKey,
            floatingActionButton: Container(
              width: 63,
              height: 63,
              child: allFiles.length == 0
                  ? null
                  : FloatingActionButton(
                      elevation: 0,
                      child: Container(
                        padding: EdgeInsets.all(11),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.blueGrey),
                        child: Icon(
                          selectedBarIndex == 2
                              ? Icons.collections_bookmark
                              : Icons.note_add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      backgroundColor: selectedBarIndex == 0
                          ? Colors.blue[50]
                          : selectedBarIndex == 1
                              ? Colors.red[50]
                              : Colors.yellow[50],
                      onPressed: () async {
                        selectedBarIndex == 2
                            ? _key.currentState.showTagDialog(context)
                            : getFile(context);
                      },
                      tooltip: 'Pick file',
                    ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            body: UpgradeAlert(
              child: selectedBarIndex == 2
                  ? TagsPage(_key, HomeState(), changeDrawer, _showSnackBar)
                  : Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 500,
                              height: 160,
                              margin: EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(36),
                                    bottomRight: Radius.circular(36)),
                                color: selectedBarIndex == 0
                                    ? Colors.blue[100]
                                    : Colors.red[100],
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 45,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 9),
                                      child: IconButton(
                                        icon: Icon(Constants.isDrawerOpen
                                            ? Icons.clear
                                            : Icons.menu),
                                        iconSize: 30,
                                        onPressed: () {
                                          changeDrawer();
                                        },
                                      ),
                                    ),
                                    Card(
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(children: [
                                          SizedBox(
                                            child: Constants.setDocType(),
                                            height: 30,
                                            width: 30,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              items: _filesTypes
                                                  .map((value) =>
                                                      DropdownMenuItem(
                                                        child: Text(value),
                                                        value: value,
                                                      ))
                                                  .toList(),
                                              value:
                                                  Constants.currentItemSelected,
                                              onChanged: (newValueSelected) {
                                                setState(() {
                                                  Constants
                                                          .currentItemSelected =
                                                      newValueSelected;
                                                  Constants.setDocType();
                                                  updateListView();
                                                });
                                              },
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.only(
                                            right: 10, bottom: 5),
                                        icon: SizedBox(
                                          child: Image.asset('Assets/sort.png'),
                                          width: 24,
                                          height: 24,
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        StateSetter
                                                            setModelState) {
                                                  Widget customRadio(
                                                      String txt, int index) {
                                                    return OutlineButton(
                                                      onPressed: () {
                                                        setModelState(() {
                                                          setState(() {
                                                            sortIndex = index;
                                                            sort = sortByIndex ==
                                                                    0
                                                                ? sortIndex
                                                                : 3 + sortIndex;
                                                            print(
                                                                '$sortIndex $sortByIndex $sort');
                                                            fileList = FileUtils
                                                                .sortList(
                                                                    fileList,
                                                                    sort);
                                                          });
                                                        });
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      borderSide: BorderSide(
                                                          color: sortIndex ==
                                                                  index
                                                              ? Colors.cyan
                                                              : Colors.grey),
                                                      child: Text(
                                                        txt,
                                                        textScaleFactor: 1.2,
                                                        style: TextStyle(
                                                            color: sortIndex ==
                                                                    index
                                                                ? Colors.cyan
                                                                : Colors.grey),
                                                      ),
                                                    );
                                                  }

                                                  Widget customRadio2(
                                                      String txt, int index) {
                                                    return OutlineButton(
                                                      onPressed: () {
                                                        setModelState(() {
                                                          setState(() {
                                                            sortByIndex = index;
                                                            sort = sortByIndex ==
                                                                    0
                                                                ? sortIndex
                                                                : 3 + sortIndex;
                                                            print(
                                                                '$sortIndex $sortByIndex $sort');
                                                            fileList = FileUtils
                                                                .sortList(
                                                                    fileList,
                                                                    sort);
                                                          });
                                                        });
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      borderSide: BorderSide(
                                                          color: sortByIndex ==
                                                                  index
                                                              ? Colors
                                                                  .deepOrangeAccent
                                                              : Colors.grey),
                                                      child: Text(
                                                        txt,
                                                        textScaleFactor: 1.1,
                                                        style: TextStyle(
                                                            color: sortByIndex ==
                                                                    index
                                                                ? Colors
                                                                    .deepOrangeAccent
                                                                : Colors.grey),
                                                      ),
                                                    );
                                                  }

                                                  return Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      height: 290,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Sort By',
                                                            textScaleFactor:
                                                                1.4,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 21,
                                                          ),
                                                          customRadio(
                                                              sortItems[0], 0),
                                                          customRadio(
                                                              sortItems[1], 1),
                                                          customRadio(
                                                              sortItems[2], 2),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          Row(
                                                            children: [
                                                              customRadio2(
                                                                  sortBy[0], 0),
                                                              SizedBox(
                                                                width: 9,
                                                              ),
                                                              customRadio2(
                                                                  sortBy[1], 1),
                                                            ],
                                                          ),
                                                        ],
                                                      ));
                                                });
                                              });
                                        })
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 35),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 7),
                                        blurRadius: 15,
                                        color:
                                            Colors.blueGrey.withOpacity(0.39),
                                      ),
                                    ],
                                  ),
                                  child: Row(children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        onChanged: (search) {
                                          setState(() {
                                            fileList = allFiles
                                                .where((f) => (f.name
                                                    .toLowerCase()
                                                    .contains(
                                                        search.toLowerCase())))
                                                .toList();
                                            count = fileList.length;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          hintText: "Search",
                                          hintStyle: TextStyle(
                                            color: Colors.blueGrey
                                                .withOpacity(0.5),
                                          ),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.blueGrey.withOpacity(0.7),
                                      ),
                                    ),
                                  ]),
                                )),
                          ],
                        ),
                        Expanded(
                          child: Stack(children: [
                            Container(
                              margin: EdgeInsets.only(top: 45),
                              padding: EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(70)),
                                color: selectedBarIndex == 0
                                    ? Colors.blue[50]
                                    : Colors.red[50],
                              ),
                              child: allFiles.length == 0
                                  ? PickButton(this)
                                  : count == 0
                                      ? Center(child: Text(Constants.emptyFile))
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 11.0),
                                          child: getFileListView(),
                                        ),
                            ),
                            !isProgressing
                                ? Container(child: null)
                                : Positioned(
                                    child: Container(
                                      child: LinearProgressIndicator(),
                                      height: 5,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                    bottom: 3,
                                  ),
                          ]),
                        ),
                      ],
                    ),
            ),
            bottomNavigationBar: AnimatedBottomBar(
              barItems: widget.barItems,
              animationDuration: const Duration(milliseconds: 450),
              barStyle: BarStyle(
                fontSize: 15.0,
                iconSize: 30.0,
              ),
              selectedIndex: selectedBarIndex,
              onBarTap: (index) {
                if (allFiles.length != 0)
                  setState(() {
                    selectedBarIndex = index;
                    updateListView();
                  });
              },
            ),
          ),
        ),
      ),
    );
  }

  ListView getFileListView() {
    return ListView.separated(
      padding: EdgeInsets.all(0),
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FocusedMenuHolder(
            duration: Duration(milliseconds: 240),
            menuWidth: MediaQuery.of(context).size.width * 0.6,
            blurSize: 3,
            blurBackgroundColor: Colors.grey,
            onPressed: () {
              try {
                OpenFile.open(fileList[position].path);
              } catch (e) {
                _showSnackBar(context, 'Error locating file');
                print(e);
              }
            },
            menuItems: [
              FocusedMenuItem(
                title: Text('Share'),
                onPressed: () {
                  Share.shareFiles([fileList[position].path],
                      text: fileList[position].name);
                },
                trailingIcon: Icon(Icons.share),
              ),
              FocusedMenuItem(
                title: Text('Rename'),
                onPressed: () {
                  String name = fileList[position].name.split('.').first;
                  _showAlertDialog(context, name, position);
                  renameCtrl.text = name;
                  renameCtrl.selection = TextSelection(
                      baseOffset: 0, extentOffset: renameCtrl.text.length);
                },
                trailingIcon: Icon(Icons.drive_file_rename_outline),
              ),
              FocusedMenuItem(
                title: Text('Tags'),
                onPressed: () {
                  _showTagsDialog(context, fileList[position].id);
                },
                trailingIcon: Icon(Icons.bookmark_border),
              ),
              FocusedMenuItem(
                  title: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    var status = await Permission.storage.status;
                    if (!status.isGranted) {
                      var result = await Permission.storage.request();
                      if (result.isDenied) {
                        _showSnackBar(
                            context, "Couldn't Delete as Permission Denied!");
                      }
                    } else {
                      File currFile = File(fileList[position].path);
                      try {
                        currFile.deleteSync(recursive: true);
                      } catch (e) {
                        print(e);
                      }
                      Navigator.pop(context);
                      _delete(context, fileList[position]);
                    }
                  },
                  trailingIcon: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.red),
            ],
            child: Card(
              color: Colors.transparent,
              //margin: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0),
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: Constants.fileImage(fileList[position].type),
                    width: 36,
                    height: 36,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileList[position].name,
                          textScaleFactor: 1.2,
                        ),
                        Row(
                          children: [
                            Text(
                              fileList[position].date,
                              textScaleFactor: 0.9,
                            ),
                            Text(
                              ' - ',
                              textScaleFactor: 0.9,
                            ),
                            Text(
                              fileList[position].size,
                              textScaleFactor: 0.9,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      fileList[position].fav == 0
                          ? Icons.favorite_border
                          : Icons.favorite,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    iconSize: 24,
                    onPressed: () {
                      setState(() {
                        fileList[position].fav = fileList[position].fav ^ 1;
                        databaseHelper.updateFileD(fileList[position]);
                        updateListView();
                      });
                    },
                  ),
                  SizedBox(
                    width: 9,
                  )
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  void _delete(BuildContext context, FileD file) async {
    int result = await databaseHelper.deleteFileD(file.id);
    if (result != 0) {
      _showSnackBar(context, 'File Removed Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 700),
    );
    //Scaffold.of(context).showSnackBar(snackBar);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> getFile(BuildContext context) async {
    isProgressing = true;
    File pickedFile;
    var status = await Permission.storage.status;
    if (status.isGranted) {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'docx',
          'doc',
          'ppt',
          'pptx',
          'xlsx',
          'xls',
          'txt',
          'jpg',
          'jpeg'
        ],
      );

      if (result != null) {
        pickedFile = File(result.files.single.path);
      }
    } else {
      var status = await Permission.storage.request();
      if (status.isDenied)
        _showSnackBar(context, 'Storage access Required');
      else
        getFile(context);
    }

    if (pickedFile != null) {
      String newPath = Constants.docDirectory + '/' + basename(pickedFile.path);

      pickedFile = await pickedFile.copy(newPath);

      file = FileD();
      file.name = basename(pickedFile.path);
      file.path = pickedFile.path;
      file.date = pickedFile.lastModifiedSync().day.toString() +
          "/" +
          pickedFile.lastModifiedSync().month.toString() +
          "/" +
          pickedFile.lastModifiedSync().year.toString();
      file.size = FileUtils.formatBytes(pickedFile.lengthSync(), 1);
      file.type = pickedFile.path.split('.').last;
      file.fav = 0;

      int result = 0;
      try {
        result = await databaseHelper.insertFileD(file);
      } catch (e) {
        if (e.toString().contains('UNIQUE')) {
          _showSnackBar(context, 'File with same name already exists');
        } else
          print(e);
      }

      if (result != 0) {
        updateListView();
        selectedBarIndex = 0;
        print(pickedFile.path);
      } else {
        // Failure
      }
    }
    isProgressing = false;
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<FileD>> fileListFuture = databaseHelper.getFileDList();
      fileListFuture.then((fileList) {
        if (fileList != null) {
          List<FileD> files = fileList;
          if (Constants.filesType != null)
            files = files
                .where((f) =>
                    (f.type.contains(Constants.filesType.substring(0, 2))))
                .toList();
          if (selectedBarIndex == 1) {
            files = files.where((f) => (f.fav == 1)).toList();
            Constants.emptyFile = 'Favourite list is empty';
          }
          setState(() {
            this.allFiles = fileList;
            this.fileList = FileUtils.sortList(files, 4);
            this.count = files.length;
          });
        }
      });
    });
    Future<List<Tag>> tagListFuture = databaseHelper.getTagList();
    tagListFuture.then((tagList) {
      if (tagList != null) {
        setState(() {
          Constants.allTagList = tagList;
        });
      }
    });
  }

  void _showAlertDialog(BuildContext context, String name, int position) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.white,
      child: Form(
        key: _formKey,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                child: TextFormField(
                  controller: renameCtrl,
                  // ignore: missing_return
                  validator: (String value) {
                    if (value.trim().isEmpty) {
                      return "Name can't be empty";
                    }
                  },
                  autofocus: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Rename",
                    hintText: "Enter new Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              OutlineButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    rename(context, name, position);
                    Navigator.pop(context);
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                borderSide: BorderSide(color: Colors.cyan),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.cyan),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  void _showTagsDialog(BuildContext context, int fileId) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add to tag',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                    letterSpacing: 1.2,
                    color: Colors.white)),
            SizedBox(
              height: 10,
            ),
            Flexible(child: getTagListView(fileId)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlineButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      selectedBarIndex = 2;
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    'New Tag',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                OutlineButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  ListView getTagListView(int fileId) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemCount: Constants.allTagList.length,
        itemBuilder: (context, i) => Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(11)),
              margin: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              color: Colors.transparent,
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 11, vertical: 0),
                title: Text(
                  Constants.allTagList[i].name,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9)),
                ),
                onTap: () {
                  Constants.allTagList[i]
                      .addFile(fileId, Constants.allTagList[i]);
                  tagsPageState.updateList();
                  //Future.delayed(Duration(milliseconds: 300),()=>Navigator.pop(context));
                  // Navigator.pop(context);
                  //print(Constants.allTagList[i].fileIds);
                  //_showSnackBar(context, 'File added to '+Constants.allTagList[i].name);
                },
              ),
            ));
  }

  void rename(BuildContext context, String name, int position) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      File currFile = File(fileList[position].path);

      String newPath = currFile.path.replaceAll(name, renameCtrl.text);

      print(currFile.path);
      print(newPath);

      int res = 0;
      try {
        currFile.renameSync(newPath);
        res = 1;
      } catch (e) {
        _showSnackBar(context, 'Error locating file');
        print(e);
      }

      if (res != 0) {
        fileList[position].path = newPath;
        fileList[position].name = basename(newPath);
        int result = 0;

        try {
          result = await databaseHelper.updateFileD(fileList[position]);
        } catch (e) {
          if (e.toString().contains('UNIQUE')) {
            _showSnackBar(context, 'File with same name already exists');
          } else
            print(e);
        }
        if (result != 0) {
          _showSnackBar(context, 'File Renamed Successfully');
          updateListView();
        }
      }
    }
  }

  void changeDrawer() {
    Constants.isDrawerOpen
        ? setState(() {
            Constants.xOffset = 0;
            Constants.yOffset = 0;
            Constants.scaleFactor = 1;
            Constants.isDrawerOpen = false;
          })
        : setState(() {
            Constants.xOffset = 210;
            Constants.yOffset = 75;
            Constants.scaleFactor = 0.85;
            Constants.isDrawerOpen = true;
          });
    print('chala toh hai');
  }

  createDir() async {
    Directory baseDir = await getExternalStorageDirectory(); //only for Android
    //Directory baseDir = await getApplicationDocumentsDirectory(); //works for both iOS and Android
    final dir = Directory(baseDir.path + "/docs");
    Constants.docDirectory = dir.path;
    //print(baseDir.path);
    bool dirExists = await dir.exists();
    if (!dirExists) {
      dir.create(/*recursive=true*/);
      //pass recursive as true if directory is recursive
    }
  }

  void showPushDialog(Map<String, dynamic> message) {
    showDialog(
      context: alertContext,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.only(top:9,bottom: 0,left: 11,right: 7),
        actionsPadding: EdgeInsets.all(0),
        title: Center(child: Text('Notification')),
        content: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(
            message['data']['title']==null?'Sorry':message['data']['title'],
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top:7.0),
            child: Text(
              message['data']['body']==null?"Couldn't load data":message['data']['body'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
