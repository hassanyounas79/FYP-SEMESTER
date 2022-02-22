// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Services/otp.dart';
import 'package:fyp/firebase/firebase.dart';

class PasswordReset {
  static errorDilog({required BuildContext context, String error = ""}) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Icon(
          Icons.error_outline_rounded,
          size: 50,
          color: Colors.red,
        ),
        actions: [
          Center(
            child: Text(error,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void reset(BuildContext context, String sSN, String user) async {
    String path;
    if (user == "admin") {
      path = "users/admin";
    } else if (user == "student") {
      path = "users/student/${sSN.toUpperCase()}";
    } else {
      path = "users/faculty/${sSN.toUpperCase()}";
    }

    late DataSnapshot ds;
    await FirebaseCon.ref.reference().child(path).once().then((value) {
      ds = value;
    });

    if (ds.exists && ds.value != null) {
      if (ds.value["status"] == 1) {
        bool b = await OTP.sendEmail(context, ds.value['email'], path);

        if (b) {
          final key = GlobalKey<FormState>();
          final TextEditingController _pass = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: Container(
                      height: MediaQuery.of(context).size.height * 0.40,
                      width: MediaQuery.of(context).size.width * 0.70,
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Form(
                        key: key,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[800]!,
                                      Colors.purple[800]!
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Change Password",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: TextFormField(
                                  controller: _pass,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (str) {
                                    if (str!.isEmpty) {
                                      return "New Password is Required";
                                    }
                                    if (str.length < 4) {
                                      return "Short Password";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      label: Text('New Password'),
                                      alignLabelWithHint: true,
                                      hintText: "New Password",
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (str) {
                                    if (str!.isEmpty) {
                                      return "Confirm Password is Required";
                                    }
                                    if (str != _pass.text) {
                                      return "Password do not match";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      label: Text('Confirm Password'),
                                      alignLabelWithHint: true,
                                      hintText: 'Confirm Password',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      var state = key.currentState;
                                      if (state!.validate()) {
                                        await FirebaseCon.ref
                                            .reference()
                                            .child(path)
                                            .update({'password': _pass.text});
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue[800]!,
                                            Colors.purple[800]!
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Change",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                );
              });
        }
      } else {
        errorDilog(context: context, error: "Unverified Account");
      }
    } else {
      errorDilog(context: context, error: "User Not Found");
    }
  }
}
