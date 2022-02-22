// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_logic_in_create_state

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp/firebase/firebase.dart';
import 'package:fyp/screens/test.dart';

class Supervisor extends StatefulWidget {
  String ssn;
  Supervisor(this.ssn, {Key? key}) : super(key: key);

  @override
  _SupervisorState createState() => _SupervisorState(ssn);
}

class _SupervisorState extends State<Supervisor> {
  _SupervisorState(this.sID);
  void getDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            // backgroundColor: Colors.transparent,
            content: Requests.widgetgetdilog(context, sID),
          );
        });
  }

  late String sID;
  bool dilog = false;
  late DataSnapshot ds;
  late String oldpassword;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text("Supervisor"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.purple[700]!,
              Colors.blue[800]!,
              Colors.purple[800]!
            ]),
          ),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 70,
              child: GestureDetector(
                onTap: () {
                  if (dilog) {
                    getDialog();
                  }
                },
                child: Stack(
                  children: [
                    Icon(
                      Icons.notification_add_outlined,
                      size: 40,
                    ),
                    StreamBuilder(
                        stream: FirebaseCon.ref
                            .reference()
                            .child("users/faculty/$sID/pending")
                            .onValue,
                        builder: (_, AsyncSnapshot<Event> snap) {
                          if (snap.hasData &&
                              snap.data!.snapshot.value != null) {
                            var mp = snap.data!.snapshot.value;
                            dilog = true;
                            return Positioned(
                              top: 0.0,
                              left: 23.0,
                              child: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${mp.length}",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            dilog = false;
                            return Text("");
                          }
                        }),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseCon.ref
                    .reference()
                    .child("users/faculty/$sID")
                    .onValue,
                builder: (_, AsyncSnapshot<Event> snap) {
                  if (snap.hasData && snap.data!.snapshot.value != null) {
                    oldpassword = snap.data!.snapshot.value["password"];
                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue[800]!, Colors.purple[800]!]),
                      ),
                      currentAccountPicture: Image(
                        image: AssetImage("images/R.png"),
                      ),
                      accountName: Text(
                        snap.data!.snapshot.value["name"],
                      ),
                      accountEmail: Text(snap.data!.snapshot.value["email"]),
                    );
                  } else {
                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue[800]!, Colors.purple[800]!]),
                      ),
                      currentAccountPicture: Image(
                        image: AssetImage("images/R.png"),
                      ),
                      accountName: Text(
                        "",
                      ),
                      accountEmail: Text(""),
                    );
                  }
                }),
            ListTile(
                leading: Icon(Icons.password_outlined),
                title: Text("Change Password"),
                onTap: () {
                  Navigator.pop(context);
                  final key = GlobalKey<FormState>();
                  final TextEditingController _pass = TextEditingController();
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: Colors.transparent,
                          content: Container(
                              height: MediaQuery.of(context).size.height * 0.50,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (str) {
                                            if (str!.isEmpty) {
                                              return "Old Password is Required";
                                            }
                                            if (str != oldpassword) {
                                              return "Incorrect Password";
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Old Password'),
                                              alignLabelWithHint: true,
                                              hintText: "Old Password",
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextFormField(
                                          controller: _pass,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
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
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
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
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () async {
                                              var state = key.currentState;
                                              if (state!.validate()) {
                                                await FirebaseCon.ref
                                                    .reference()
                                                    .child("users/faculty/$sID")
                                                    .update({
                                                  'password': _pass.text
                                                });
                                              }
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                  msg: "Password Updated",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                      fontWeight:
                                                          FontWeight.bold),
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
                }),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseCon.ref
              .reference()
              .child("users/faculty/$sID/approved")
              .onValue,
          builder: (_, AsyncSnapshot<Event> snap) {
            if (snap.hasData && snap.data!.snapshot.value != null) {
              return Center(
                child: Requests.approved(context, sID),
              );
            } else {
              return Center(
                child: Text("No Approved Projects"),
              );
            }
          }),
    );
  }
}
