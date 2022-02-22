// ignore_for_file: file_names, prefer_const_constructors, unused_local_variable, avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp/firebase/firebase.dart';

class Student extends StatefulWidget {
  String ssn;
  Student(this.ssn, {Key? key}) : super(key: key);

  @override
  _StudentState createState() => _StudentState(ssn);
}

class _StudentState extends State<Student> {
  _StudentState(this.regNo);
  final FirebaseDatabase ref = FirebaseDatabase.instance;
  bool dropdown = true;
  late String regNo;
  final ptKey = GlobalKey<FormState>();
  final gmKey = GlobalKey<FormState>();
  final sKey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> projectList(var ds) {
    List<DropdownMenuItem<String>> plist = [];
    int a = 0;

    if (ds.exists) {
      Map map = ds.value;
      map.forEach((key, value) {
        if (value['selected'] == 0) {
          plist.add(DropdownMenuItem(
              child: Text("${value["title"]}"), value: key.toString()));
        }
      });
    }
    return plist;
  }

  List<DropdownMenuItem<String>> supervisorList(DataSnapshot ds) {
    List<DropdownMenuItem<String>> plist = [];
    if (ds.exists) {
      Map abc = ds.value;
      abc.forEach((key, value) {
        int projects = value['projects'];
        if (projects < 7) {
          plist.add(DropdownMenuItem(
            child: Text(value['name']),
            value: key,
          ));
        }
      });
    }
    return plist;
  }

  List<DropdownMenuItem<String>> groupMemberList(DataSnapshot ds) {
    List<DropdownMenuItem<String>> plist = [
      DropdownMenuItem(
        child: Text("NONE"),
        value: "NONE",
      )
    ];
    var reg = regNo.split('-');
    String batch = reg[0] + '-' + reg[1];
    if (ds.exists) {
      Map abc = ds.value;
      abc.forEach(
        (key, valu) {
          if (key.toString().contains(batch) &&
              key.toString().toUpperCase() != regNo.toUpperCase()) {
            if (valu['projectNo'] == null) {
              plist.add(
                DropdownMenuItem(
                  child: Text(key.toString().toUpperCase()),
                  value: key,
                ),
              );
            }
          }
        },
      );
    }
    return plist;
  }

  Future<int> getLength() async {
    late DataSnapshot ds;
    int lenth = 0;
    await FirebaseCon.ref
        .reference()
        .child("pending_projects")
        .once()
        .then((value) => ds = value);
    if (ds.exists) {
      Map mp = ds.value;
      mp.forEach((key, value) {
        int keylenth = key.toString().length;
        String str = key;
        lenth = int.parse(str.substring(1, keylenth));
      });
    }
    lenth++;
    return lenth;
  }

  void sendConsent(String pt, String gm, String sup) async {
    dropdown = false;
    int lenth = await getLength();
    late String projectName;
    Navigator.pop(context);
    await FirebaseCon.ref
        .reference()
        .child("projects/$pt")
        .once()
        .then((value) {
      projectName = value.value['title'];
    });
    try {
      await FirebaseCon.ref
          .reference()
          .child("projects/$pt")
          .update({'selected': 1});
    } catch (e) {}
    print(pt);
    if (gm == "NONE") {
      Map<String, dynamic> map = {
        "_$lenth": {
          'stdID': regNo,
          'status': 'pending',
          'pid': pt,
          'project-title': projectName,
          'supervisor': sup
        }
      };
      try {
        await FirebaseCon.ref.reference().child("pending_projects").update(map);
      } catch (e) {}
      try {
        await FirebaseCon.ref
            .reference()
            .child("users/student/$regNo")
            .update({'projectNo': '_$lenth'});
      } catch (e) {}
      try {
        await FirebaseCon.ref
            .reference()
            .child("users/faculty/$sup/pending")
            .update({"_$lenth": '_$lenth'});
      } catch (e) {}
    } else {
      Map<String, dynamic> map = {
        "_$lenth": {
          'stdID': regNo,
          'GroupMember': gm,
          'status': 'pending',
          'pid': pt,
          'project-title': projectName,
          'supervisor': sup
        }
      };
      try {
        await FirebaseCon.ref.reference().child("pending_projects").update(map);
      } catch (e) {}
      try {
        await FirebaseCon.ref
            .reference()
            .child("users/student/$regNo")
            .update({'projectNo': '_$lenth'});
      } catch (e) {}
      try {
        await FirebaseCon.ref
            .reference()
            .child("users/student/$gm")
            .update({'projectNo': '_$lenth'});
      } catch (e) {}
      try {
        await FirebaseCon.ref
            .reference()
            .child("users/faculty/$sup/pending")
            .update({'_$lenth': '_$lenth'});
      } catch (e) {}
    }
    Fluttertoast.showToast(
        msg: "Request Submitted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String projectNo = "";
  String gMRegNo = "NONE";
  String supId = "";
  late String oldpassword;
  @override
  Widget build(BuildContext context) {
    double devHeight = MediaQuery.of(context).size.height;
    double devWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: Colors.red[100],
      appBar: AppBar(
        elevation: 10,
        title: Text("Student"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.purple[700]!,
              Colors.blue[800]!,
              Colors.purple[800]!
            ]),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseCon.ref
                    .reference()
                    .child("users/student/$regNo")
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
                                                    .child(
                                                        "users/student/$regNo")
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

      body: SizedBox(
        height: devHeight,
        width: devWidth,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Project Title",
                            softWrap: true,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: StreamBuilder(
                            stream: ref.reference().child("projects").onValue,
                            builder: (context, AsyncSnapshot<Event> snap) {
                              if (snap.hasData && dropdown) {
                                return Form(
                                  key: ptKey,
                                  child: DropdownButtonFormField(
                                    elevation: 16,
                                    alignment: AlignmentDirectional.bottomStart,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onSaved: (str) {
                                      projectNo = str.toString();
                                    },
                                    validator: (str) {
                                      if (str == null) {
                                        return "";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    dropdownColor: Colors.white,
                                    hint: Text("Select Project Title"),
                                    onChanged: (str) {},
                                    items: projectList(snap.data!.snapshot),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "Group Member",
                              softWrap: true,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 4,
                          child: StreamBuilder(
                            stream:
                                ref.reference().child("users/student").onValue,
                            builder: (context, AsyncSnapshot<Event> snap) {
                              if (snap.hasData && dropdown) {
                                return Form(
                                  key: gmKey,
                                  child: DropdownButtonFormField(
                                    elevation: 16,
                                    value: gMRegNo,
                                    alignment: AlignmentDirectional.bottomStart,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onSaved: (str) {
                                      gMRegNo = str.toString();
                                    },
                                    validator: (str) {
                                      if (str == null) {
                                        return "";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    dropdownColor: Colors.white,
                                    hint: Text("Select Group Member"),
                                    onChanged: (str) {},
                                    items: groupMemberList(snap.data!.snapshot),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Supervisor",
                            softWrap: true,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: StreamBuilder(
                            stream:
                                ref.reference().child("users/faculty").onValue,
                            builder: (context, AsyncSnapshot<Event> snap) {
                              if (snap.hasData && dropdown) {
                                return Form(
                                  key: sKey,
                                  child: DropdownButtonFormField(
                                    elevation: 16,
                                    alignment: AlignmentDirectional.bottomStart,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onSaved: (str) {
                                      supId = str.toString();
                                    },
                                    validator: (str) {
                                      if (str == null) {
                                        return "";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    dropdownColor: Colors.white,
                                    hint: Text("Select Supervisor"),
                                    onChanged: (str) {},
                                    items: supervisorList(snap.data!.snapshot),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 8,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      var a = ptKey.currentState;
                      var b = gmKey.currentState;
                      var c = sKey.currentState;
                      if (a!.validate() && b!.validate() && c!.validate()) {
                        a.save();
                        b.save();
                        c.save();
                        sendConsent(projectNo, gMRegNo, supId);
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            colors: [Colors.blue[800]!, Colors.purple[900]!]),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Send Consent",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
