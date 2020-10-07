import 'package:document_organizer/utils/database_helper.dart';

class Tag{
  int _id;
  String _name;
  String _fileIds;

  DatabaseHelper databaseHelper = DatabaseHelper();
  Tag.withID(this._id, this._name,  this._fileIds);

  Tag(this._name,this._fileIds);

  int get id => _id;


  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get fileIds => _fileIds;

  set fileIds(String value) {
    _fileIds = value;
  }

  Map<String,dynamic> toMap() {
    return {

      if(id != null)
        'id': _id,
      'name': _name,
      'fileIds': _fileIds,
    };
  }

  Tag.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._fileIds = map['fileIds'];
  }

  List<String> toList(){
    return _fileIds.substring(1,_fileIds.length-1).split(',');
  }

  void addFile(int fileId,Tag tag){
    //print(_fileIds);
    List fileIdListX=_fileIds.substring(1,_fileIds.length-1).split(','); //'\\s*,\\s*'
    List<int> fileIdList=List();
    if(fileIdListX.first!='')
    fileIdListX.forEach((element) {fileIdList.add(int.parse(element.trim()));});
    if(fileIdListX.first!=''){
      fileIdList.add(fileId);
      //print(fileIdList.length);
      _fileIds=fileIdList.toSet().toList().toString();
    }
   else{
     _fileIds='['+fileId.toString()+']';
    }
    databaseHelper.updateTag(tag);
  }

  void deleteFile(int fileId,Tag tag){
    //print(_fileIds);
    List fileIdListX=_fileIds.substring(1,_fileIds.length-1).split(','); //'\\s*,\\s*'
    List<int> fileIdList=List();
    if(fileIdListX.first!='')
      fileIdListX.forEach((element) {fileIdList.add(int.parse(element.trim()));});
    if(fileIdListX.first!=''){
      fileIdList.remove(fileId);
      //print(fileIdList.length);
      _fileIds=fileIdList.toSet().toList().toString();
    }
    else{
      _fileIds='['+fileId.toString()+']';
    }
    databaseHelper.updateTag(tag);
  }

}