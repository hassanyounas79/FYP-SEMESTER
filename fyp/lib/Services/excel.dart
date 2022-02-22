// ignore_for_file: import_of_legacy_library_into_null_safe, unused_local_variable

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExcelRead {
  static List<dynamic> list = [];
  static late List students = [];
  static late List faculty = [];
  static late List stdId = [];
  static late List facId = [];
  static late bool valid = true;
  static Future<void> read(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      list = [];

      if (excel.tables[table]!.maxCols != 4) {
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
      excel.tables[table]!.removeRow(0);
      excel.tables[table]!.removeColumn(0);
      excel.tables[table]!.removeColumn(3);
      for (var row in excel.tables[table]!.rows) {
        if (row[1] != null) {
          list.add(row);
        }
      }
    }
    if (valid) {
      bindToList();
    }
  }

  static bindToList() {
    students = [];
    faculty = [];
    stdId = [];
    facId = [];
    for (var item in list) {
      if (item[2] == "Student") {
        Map<String, dynamic> mp = {
          item[0]: {'name': item[1], 'password': item[0], 'status': 0}
        };
        stdId.add(item[0]);
        students.add(mp);
      } else if (item[2] == "Faculty") {
        Map<String, dynamic> mp = {
          item[0]: {
            'name': item[1],
            'password': item[0],
            'projects': 0,
            'status': 0
          }
        };
        facId.add(item[0]);
        faculty.add(mp);
      }
    }
    createUsers();
  }

  static createUsers() async {
    var ref = FirebaseDatabase.instance.reference();
    late DataSnapshot ds;
    var std =
        await ref.child("users/student").once().then((value) => {ds = value});
    int a = 0;
    for (var stdid in stdId) {
      if (ds.value != null) {
        if (ds.value[stdid.toString()] == null) {
          await ref.reference().child("users/student").update(students[a]);
        }
      } else {
        await ref.reference().child("users/student").update(students[a]);
      }
      a++;
    }

    std = await ref.child("users/faculty").once().then((value) => {ds = value});
    a = -1;
    for (var facid in facId) {
      a++;
      if (ds.value != null) {
        if (ds.value[facid.toString()] == null) {
          await ref.reference().child("users/faculty").update(faculty[a]);
        }
      } else {
        await ref.reference().child("users/faculty").update(faculty[a]);
      }
    }
    list = [];
    faculty = [];
    students = [];
    facId = [];
    stdId = [];
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
