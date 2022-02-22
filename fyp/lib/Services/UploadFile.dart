// ignore_for_file: import_of_legacy_library_into_null_safe, file_names, prefer_typing_uninitialized_variables, unused_local_variable, avoid_print
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyp/firebase/firebase.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadFile {
  static List<dynamic> list = [];
  static late bool valid = true;
  static Future<void> read(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      if (excel.tables[table]!.maxCols != 2) {
        valid = false;
        Fluttertoast.showToast(
            msg: "Incorrect File",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      list = [];
      excel.tables[table]!.removeRow(0);
      excel.tables[table]!.removeColumn(0);
      excel.tables[table]!.removeColumn(1);
      for (var row in excel.tables[table]!.rows) {
        if (row[0] != null) {
          list.add(row);
        }
      }
    }
    if (valid) {
      uploadList();
    }
  }

  static void uploadList() async {
    late DataSnapshot ds;
    var dt = await FirebaseCon.ref
        .reference()
        .child("projects")
        .once()
        .then((value) => {ds = value});
    late var pre = [];
    late int a = -1;
    if (ds.value != null) {
      Map mp = ds.value;
      mp.forEach((key, value) {
        int keylenth = key.toString().length;
        String str = key;
        a = int.parse(str.substring(1, keylenth));
        pre.add(value['title'].toString().toUpperCase());
      });
      a++;
      for (var item in list) {
        if (!pre.contains(item[0].toString().toUpperCase())) {
          Map<String, dynamic> map = {
            "_$a": {
              'title': item[0],
              'selected': 0,
            }
          };
          await FirebaseCon.ref.reference().child("projects").update(map);
          a++;
        }
      }
    } else {
      a = 1;
      for (var item in list) {
        Map<String, dynamic> map = {
          "_$a": {
            'title': item[0],
            'selected': 0,
          }
        };
        await FirebaseCon.ref.reference().child("projects").update(map);
        a++;
      }
    }
    Fluttertoast.showToast(
        msg: "Uploaded Succesully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
