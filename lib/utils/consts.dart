import 'package:document_organizer/screens/tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Constants {
  static double xOffset = 0;
  static double yOffset = 0;
  static double scaleFactor = 1;

  static bool isDrawerOpen = false;

  static String currentItemSelected='All Documents';
  static String filesType;
  static String emptyFile = '';
  static String docDirectory;


  static var allFileList;
  static var allTagList;

  static Image setDocType() {
    Image image=Image.asset('Assets/doc.png');
    switch (currentItemSelected) {
      case 'All Documents':
        filesType = null;
        image = Image.asset('Assets/doc.png');
        return image;
        break;

      case 'PDF':
        filesType = 'pdf';
        image = Image.asset('Assets/pdf.png');
        emptyFile = 'No files of PDF type at this moment';
        return image;
        break;

      case 'DOC':
        filesType = 'docx';
        image = Image.asset('Assets/docx.png');
        emptyFile = 'No files of DOC type at this moment';
        return image;
        break;

      case 'PPT':
        filesType = 'pptx';
        image = Image.asset('Assets/ppt.png');
        emptyFile = 'No files of PPT type at this moment';
        return image;
        break;

      case 'XLS':
        filesType = 'xlsx';
        image = Image.asset('Assets/xls.png');
        emptyFile = 'No files of EXCEL type at this moment';
        return image;
        break;

      case 'TXT':
        filesType = 'txt';
        image = Image.asset('Assets/txt.png');
        emptyFile = 'No files of TEXT type at this moment';
        return image;
        break;
      case 'JPG':
        filesType = 'jp';
        image = Image.asset('Assets/jpg.png');
        emptyFile = 'No image file at this moment';
        return image;
        break;
      default:
        image = Image.asset('Assets/doc.png');
        return image;
    }
  }

  static Image fileImage(String type) {
    Image _image=Image.asset('Assets/doc.png');
    switch (type) {
      case 'pdf':
        _image = Image.asset('Assets/pdf.png');
        return _image;
        break;

      case 'docx':
        _image = Image.asset('Assets/docx.png');
        return _image;
        break;
      case 'doc':
        _image = Image.asset('Assets/docx.png');
        return _image;
        break;

      case 'pptx':
        _image = Image.asset('Assets/ppt.png');
        return _image;
        break;
      case 'ppt':
        _image = Image.asset('Assets/ppt.png');
        return _image;
        break;

      case 'xlsx':
        _image = Image.asset('Assets/xls.png');
        return _image;
        break;
      case 'xls':
        _image = Image.asset('Assets/xls.png');
        return _image;
        break;

      case 'txt':
        _image = Image.asset('Assets/txt.png');
        return _image;
        break;
      case 'jpg':
        _image = Image.asset('Assets/jpg.png');
        return _image;
        break;
      case 'jpeg':
        _image = Image.asset('Assets/jpg.png');
        return _image;
        break;
      default:
        _image = Image.asset('Assets/doc.png');
        return _image;
    }
  }
}



