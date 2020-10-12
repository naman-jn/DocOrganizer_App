import 'package:document_organizer/models/file.dart';
import 'package:document_organizer/models/tag.dart';
import 'package:document_organizer/screens/home.dart';
import 'package:document_organizer/utils/consts.dart';
import 'package:document_organizer/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';


class TagsPage extends StatefulWidget {
  final HomeState homeState;
  final Function changeDrawer;
  final Function showSnackBar;

  TagsPage(Key key, this.homeState, this.changeDrawer, this.showSnackBar)
      : super(key: key);

  @override
  TagsPageState createState() => TagsPageState();
}

class TagsPageState extends State<TagsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  static List<Tag> tagList;
  static int count = tagList.length;

  TextEditingController tagCtrl = TextEditingController();
  TextEditingController renameCtrl = TextEditingController();

  var _createFormKey = GlobalKey<FormState>();
  var _renameFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (tagList == null) {
      tagList = List<Tag>();
      updateListView();
    }
    Constants.allTagList = tagList;
    return Container(
      color: Colors.yellow[50],
      child: Stack(
        children: [
          Container(
            width: 500,
            height: 100,
            margin: EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36)),
              color: Colors.yellow[100],
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: IconButton(
                        icon: Icon(
                            Constants.isDrawerOpen ? Icons.clear : Icons.menu),
                        iconSize: 30,
                        onPressed: () {
                          //widget.homeState.changeDrawer();
                          widget.changeDrawer();
                        },
                      )),
                  Text(
                    'TAGs',
                    style: TextStyle(
                        letterSpacing: 1,
                        fontSize: 19,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    width: 65,
                  ),
                ],
              ),
              SizedBox(
                height: 11,
              ),
              Expanded(
                  child: tagList.length == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  //width: 270,
                                  child: Image.asset('Assets/emptyTag.png')),
                              SizedBox(height: 7,),
                              Text('Looks A Little Empty Here',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey[300],fontSize: 20),),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Press the ',style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 15,letterSpacing: 1),),
                                  Icon(Icons.create_new_folder_outlined,size: 18,),
                                  Text(' button to create new tag',style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 15,letterSpacing: 1),),
                                ],
                              )

                            ],
                          ))
                      : getTagListView()),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTagListView() {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
            Duration(milliseconds: 1100), () => updateListView());
      },
      color: Colors.blue,
      backgroundColor: Colors.yellow[100],
      child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: tagList.length,
          itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FocusedMenuHolder(
                  duration: Duration(milliseconds: 240),
                  menuWidth: MediaQuery.of(context).size.width * 0.6,
                  blurSize: 3,
                  blurBackgroundColor: Colors.grey,
                  onPressed: () {},
                  menuItems: [
                    FocusedMenuItem(
                      title: Text('Add File'),
                      onPressed: () {
                        _showAddFileDialog(context, tagList[i]);
                      },
                      trailingIcon: Icon(Icons.note_add),
                    ),
                    FocusedMenuItem(
                      title: Text('Rename Tag'),
                      onPressed: () {
                        String name = tagList[i].name;
                        _showRenameDialog(context, i);
                        renameCtrl.text = name;
                        renameCtrl.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: renameCtrl.text.length);
                      },
                      trailingIcon: Icon(Icons.drive_file_rename_outline),
                    ),
                    FocusedMenuItem(
                        title: Text('Delete Tag',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          _delete(context, tagList[i]);
                        },
                        trailingIcon: Icon(
                          Icons.delete_sweep,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red),
                  ],
                  child: ExpansionTile(
                    childrenPadding: EdgeInsets.only(bottom: 10),
                    title: Text(
                      tagList[i].name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 1.5,
                          color: Colors.blueGrey),
                    ),
                    children: tagList[i]
                        .toList()
                        .map((fileId) => fileId == ''
                            ? Text(
                                'File list empty\nPress & hold to add Files',
                                textAlign: TextAlign.center,
                              )
                            : getCard(fileId, tagList[i]))
                        .toList(),
                  ),
                ),
              )),
    );
  }

  Widget getCard(String fileId, Tag tag) {
    FileD file;
    try {
      file = Constants.allFileList
          .firstWhere((file) => file.id == int.parse(fileId));
    } catch (exception) {
      return Container(
        color: Colors.red.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'File not found(id-$fileId)',
                textAlign: TextAlign.center,
              ),
              IconButton(
                  icon: Icon(
                    Icons.delete_sweep,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      tag.deleteFile(int.parse(fileId), tag);
                    });
                  })
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FocusedMenuHolder(
        duration: Duration(milliseconds: 240),
        menuWidth: MediaQuery.of(context).size.width * 0.6,
        blurSize: 3,
        blurBackgroundColor: Colors.grey,
        onPressed: () {
          try {
            OpenFile.open(file.path);
            if(!File(file.path).existsSync())
              widget.showSnackBar(context, 'Error locating file');
          } catch (e) {
            widget.showSnackBar(context, 'Error locating file');
            print(e);
          }
        },
        menuItems: [
          FocusedMenuItem(
            title: Text('Remove File Tag'),
            trailingIcon: Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                tag.deleteFile(int.parse(fileId), tag);
              });
            },
          ),
          FocusedMenuItem(
            title: Text('Share'),
            trailingIcon: Icon(Icons.share),
            onPressed: () {
              Share.shareFiles([file.path], text: file.name);
            },
          ),
        ],
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Constants.fileImage(file.type),
                width: 33,
                height: 33,
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      textScaleFactor: 1.1,
                    ),
                    Row(
                      children: [
                        Text(
                          file.date,
                          textScaleFactor: 0.8,
                        ),
                        Text(
                          ' - ',
                          textScaleFactor: 0.8,
                        ),
                        Text(
                          file.size,
                          textScaleFactor: 0.8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  file.fav == 0 ? Icons.favorite_border : Icons.favorite,
                  color: Colors.red.withOpacity(0.7),
                ),
                iconSize: 21,
                onPressed: () {
                  setState(() {
                    file.fav = file.fav ^ 1;
                    databaseHelper.updateFileD(file);
                    //updateListView();
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
  }

  void showTagDialog(BuildContext context) {
    tagCtrl.text = '';
    Dialog dialog = Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Form(
        key: _createFormKey,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                child: TextFormField(
                  controller: tagCtrl,
                  // ignore: missing_return
                  validator: (String value) {
                    if (value.trim().isEmpty) {
                      return "Name can't be empty";
                    }
                  },
                  autofocus: true,
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: "Create Tag",
                    labelStyle: TextStyle(fontSize: 19),
                    hintText: "Enter Tag Name",
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              OutlineButton(
                onPressed: () async {
                  if (_createFormKey.currentState.validate()) {
                    createTag(context, tagCtrl.text);
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

  void _showAddFileDialog(BuildContext context, Tag tag) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add file to tag',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                    letterSpacing: 1.2,
                    color: Colors.white)),
            SizedBox(
              height: 10,
            ),
            Flexible(child: getFileListView(tag)),
            SizedBox(
              height: 10,
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
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  ListView getFileListView(Tag tag) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemCount: Constants.allFileList.length,
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
                  Constants.allFileList[i].name,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9)),
                ),
                onTap: () {
                  tag.addFile(Constants.allFileList[i].id, tag);
                  //Navigator.pop(context);
                  setState(() {});
                },
              ),
            ));
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Tag>> tagListFuture = databaseHelper.getTagList();
      tagListFuture.then((tagList) {
        if (tagList != null) {
          setState(() {
            TagsPageState.tagList = tagList..sort((t1, t2) => (t1.name)
                .toLowerCase()
                .compareTo((t2.name).toLowerCase()));
            //this.count = tagList.length;
          });
        }
      });
    });
  }

  void updateList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Tag>> tagListFuture = databaseHelper.getTagList();
      tagListFuture.then((tagList) {
        if (tagList != null) {
          TagsPageState.tagList = tagList..sort((t1, t2) => (t1.name)
              .toLowerCase()
              .compareTo((t2.name).toLowerCase()));
        }
      });
    });
  }

  void _showRenameDialog(BuildContext context, int position) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.white,
      child: Form(
        key: _renameFormKey,
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
                      return "Tag name can't be empty";
                    }},
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
                  if (_renameFormKey.currentState.validate()) {
                    updateTag(context, position);
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

  void _delete(BuildContext context, Tag tag) async {
    int result = await databaseHelper.deleteTag(tag.id);
    if (result != 0) {
      updateListView();
    }
  }

  void createTag(BuildContext context, String name) async {
    Tag tag = Tag('$name', '[]');

    int result = 0;
    try {
      result = await databaseHelper.insertTag(tag);
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        widget.showSnackBar(context, 'Tag already exists');
      } else
        print(e);
    }

    if (result != 0) {
      this.updateListView();
    } else {}
  }

  Future<void> updateTag(BuildContext context, int position) async {
    int result=0;
    String temp= tagList[position].name;
    tagList[position].name=renameCtrl.text;
    try {
      result = await databaseHelper.updateTag(tagList[position]);
      print(tagList[position].name);
    }
    catch(e){
      if (e.toString().contains('UNIQUE'))
      {
        widget.showSnackBar(context, 'Tag already exists');
        tagList[position].name=temp;
      }
      else
        print(e);
    }
    if (result != 0) {
      widget.showSnackBar(context, 'Tag Renamed Successfully');
      updateListView();
    }
  }

}
