// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/firebase/firebase.dart';

class Requests {
  static widgetgetdilog(var context, String sID) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      width: MediaQuery.of(context).size.width * 0.90,
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.blue[800]!, Colors.purple[800]!]),
        boxShadow: const [
          BoxShadow(color: Colors.grey, blurRadius: 80, spreadRadius: 10)
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder(
          stream: FirebaseCon.ref.reference().child("").onValue,
          builder: (context, AsyncSnapshot<Event> snap) {
            if (snap.hasData && snap.data!.snapshot.value != null) {
              DataSnapshot snapDs = snap.data!.snapshot;
              return StreamBuilder(
                  stream: FirebaseCon.ref
                      .reference()
                      .child("users/faculty/$sID/pending")
                      .onValue,
                  builder: (context, AsyncSnapshot<Event> snap2) {
                    if (snap2.hasData && snap2.data!.snapshot.exists) {
                      var values = [];
                      Map mp = snap2.data!.snapshot.value;
                      mp.forEach((key, value) {
                        values.add(value);
                      });
                      values = List.from(values.reversed);
                      if (snap2.hasData &&
                          snap2.data!.snapshot.value != null) {}
                      return Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    " SuperVision Requests",
                                    maxLines: 1,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 12,
                            child: ListView.builder(
                                padding: EdgeInsets.only(),
                                itemCount: values.length,
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  int pNO = snapDs.value["users"]["faculty"]
                                      [sID]['projects'];
                                  late String sup = "";
                                  late String temp = "";
                                  late String name = "";
                                  late String name2 = "";
                                  late String projectTitle = "";
                                  late String temp2 = "";
                                  late String name3 = "";
                                  String gm = "";

                                  try {
                                    sup = snapDs.value["pending_projects"]
                                        ["${values[index]}"]["supervisor"];
                                    gm = snapDs.value["pending_projects"]
                                                ["${values[index]}"]
                                            ["GroupMember"] ??
                                        "";
                                  } catch (e) {}
                                  try {
                                    name3 = snapDs.value["users"]["faculty"]
                                        [sup]["name"];
                                    temp = snapDs.value["pending_projects"]
                                        ["${values[index]}"]["stdID"];
                                    name = snapDs.value["users"]["student"]
                                        [temp]["name"];
                                    projectTitle = snapDs
                                            .value["pending_projects"]
                                        ["${values[index]}"]["project-title"];
                                    if (gm != "") {
                                      temp2 = snapDs.value["pending_projects"]
                                          ["${values[index]}"]["GroupMember"];
                                      name2 = snapDs.value["users"]["student"]
                                          [temp2]["name"];
                                    }
                                  } catch (e) {}
                                  return GestureDetector(
                                    onLongPress: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              actionsAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              title: Text("Approval"),
                                              content: Text(
                                                  "Do you want to Supervise this Project?"),
                                              actions: [
                                                ElevatedButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    String pid = await FirebaseCon
                                                        .ref
                                                        .reference()
                                                        .child(
                                                            "pending_projects/${values[index]}")
                                                        .once()
                                                        .then((value) =>
                                                            value.value["pid"]);
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child("projects/$pid")
                                                        .update(
                                                            {'selected': 0});
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/student/$temp/projectNo")
                                                        .remove();
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/student/$temp2/projectNo")
                                                        .remove();
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "pending_projects/${values[index]}")
                                                        .remove();
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/faculty/$sID/pending/${values[index]}")
                                                        .remove();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Reject"),
                                                ),
                                                ElevatedButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/faculty/$sID")
                                                        .update({
                                                      'projects': pNO + 1,
                                                    });
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/faculty/$sID/approved")
                                                        .update({
                                                      '${values[index]}':
                                                          '${values[index]}'
                                                    });
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "pending_projects/${values[index]}")
                                                        .update({
                                                      'status': 'semi-approved'
                                                    });

                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/admin/pending")
                                                        .update({
                                                      values[index]:
                                                          values[index]
                                                    });
                                                    await FirebaseCon.ref
                                                        .reference()
                                                        .child(
                                                            "users/faculty/$sID/pending/${values[index]}")
                                                        .remove();
                                                  },
                                                  child: Text("Yes"),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 20, right: 20, bottom: 10),
                                      height: 120,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[350],
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                temp,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                name,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          gm != ""
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                      temp2,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      name2,
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                )
                                              : Text(""),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                "Project Title",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                projectTitle,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    } else {
                      return const Text("");
                    }
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  static approved(var context, String sID) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      width: MediaQuery.of(context).size.width * 0.90,
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.blue[800]!, Colors.purple[800]!]),
        boxShadow: const [
          BoxShadow(color: Colors.grey, blurRadius: 80, spreadRadius: 10)
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder(
          stream: FirebaseCon.ref.reference().child("").onValue,
          builder: (context, AsyncSnapshot<Event> snap) {
            if (snap.hasData && snap.data!.snapshot.value != null) {
              DataSnapshot snapDs = snap.data!.snapshot;
              return StreamBuilder(
                  stream: FirebaseCon.ref
                      .reference()
                      .child("users/faculty/$sID/approved")
                      .onValue,
                  builder: (context, AsyncSnapshot<Event> snap2) {
                    if (snap2.hasData && snap2.data!.snapshot.exists) {
                      var values = [];
                      Map mp = snap2.data!.snapshot.value;
                      mp.forEach((key, value) {
                        values.add(value);
                      });
                      values = List.from(values.reversed);
                      if (snap2.hasData &&
                          snap2.data!.snapshot.value != null) {}
                      return Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    " Approved Projects",
                                    maxLines: 1,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 12,
                            child: ListView.builder(
                                padding: EdgeInsets.only(),
                                itemCount: values.length,
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  int pNO = snapDs.value["users"]["faculty"]
                                      [sID]['projects'];
                                  late String temp;
                                  late String temp2;
                                  String gm = "";
                                  try {
                                    gm = snapDs.value["pending_projects"]
                                                ["${values[index]}"]
                                            ["GroupMember"] ??
                                        "";
                                  } catch (e) {}
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 20, right: 20, bottom: 10),
                                    height: 120,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[350],
                                        borderRadius: BorderRadius.circular(7)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "${temp = snapDs.value["pending_projects"]["${values[index]}"]["stdID"]}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${snapDs.value["users"]["student"][temp]["name"]}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        gm != ""
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    "${temp2 = snapDs.value["pending_projects"]["${values[index]}"]["GroupMember"]}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${snapDs.value["users"]["student"][temp2]["name"]}",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              )
                                            : Text(""),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Project Title",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${snapDs.value["pending_projects"]["${values[index]}"]["project-title"]}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    } else {
                      return const Text("");
                    }
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
