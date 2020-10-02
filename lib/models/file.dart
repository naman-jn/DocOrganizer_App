class FileD{
  int _id;
  String _name;
  String _path;
  String _date;
  String _size;
  String _type;
  int _fav;

  FileD.withID(this._id, this._name,  this._path, this._date, this._size, this._type,this._fav);

 //FileD(this._name, this._path, this._date, this._size, this._type);
  FileD();

  int get id => _id;

  String get path => _path;

  set path(String value) {
    _path = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get size => _size;

  set size(String value) {
    _size = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }


  int get fav => _fav;

  set fav(int value) {
    _fav = value;
  }

  Map<String,dynamic> toMap() {
    return {

      if(id != null)
        'id': _id,
      'name': _name,
      'size': _size,
      'date': _date,
      'path': _path,
      'type':_type,
      'fav':_fav,

    };
  }

  FileD.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._size = map['size'];
    this._path = map['path'];
    this._date = map['date'];
    this._type = map['type'];
    this._fav=map['fav'];
  }


}