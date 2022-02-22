// ignore_for_file: prefer_const_constructors, deprecated_member_use, empty_catches, unused_element

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/Services/connection.dart';
import 'package:fyp/Services/reset.dart';
import 'package:fyp/firebase/firebase.dart';
import 'package:fyp/screens/admin.dart';
import 'package:fyp/screens/student.dart';
import 'package:fyp/screens/supervisor.dart';
import '../Services/email.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final employeeId = TextEditingController();
  final employeePin = TextEditingController();
  final FocusNode buttonfocus = FocusNode();
  String resetUser = "";
  createDilog(Map project) async {
    bool gMember = project["GroupMember"] != null ? true : false;
    late String name;
    late String name2;
    late String sName;

    await FirebaseCon.ref.reference().child("users").once().then((value) {
      name = value.value["student"]["${project["stdID"]}"]["name"];
      if (gMember) {
        name2 = value.value["student"]["${project["stdID"]}"]["name"];
      }
      sName = value.value["faculty"]["${project["supervisor"]}"]["name"];
    });
    String message = project["status"] == "approved"
        ? "Your project is approved!"
        : project["status"] == "pending"
            ? "Your Project is submitted to Supervisor wait for approval!"
            : "Your Project is pending for approval from admin!";

    showDialog(
        context: _scaffoldKey.currentContext as BuildContext,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: MediaQuery.of(context).size.width * 0.85,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
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
                          colors: [Colors.blue[800]!, Colors.purple[800]!],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Project Status",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  project["stdID"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                gMember
                                    ? Text(project["GroupMember"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))
                                    : Text(""),
                                Text("Project Title",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("Supervisor",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name),
                                gMember ? Text(name2) : Text(""),
                                Text(project["project-title"]),
                                Text(sName),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(message,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ))
                  ],
                )),
          );
        });
  }

  void checkStatus(String ssn, String u, String pass) async {
    bool conection = await Connection.tryConnection();
    if (conection) {
      String path = "";
      if (ssn.toLowerCase().contains(u)) {
        path = "users/admin";
      } else {
        path = "users/" + u + "/" + ssn.toUpperCase();
      }
      var ref = FirebaseDatabase.instance.reference().child(path);
      await ref.once().then(
        (value) async {
          Navigator.pop(context);

          if (value.exists) {
            if (value.value["password"].toString() == pass) {
              if (value.value["status"].toString() == '0') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Email(
                      ssn,
                      user,
                    ),
                  ),
                );
              } else {
                if (u.contains("admin")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Admin(),
                    ),
                  );
                } else if (u.contains("student")) {
                  if (value.value['projectNo'] != null) {
                    DataSnapshot ds = await FirebaseCon.ref
                        .reference()
                        .child("pending_projects/${value.value['projectNo']}")
                        .once()
                        .then((value) => value);

                    createDilog(ds.value);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Student(ssn.toUpperCase()),
                      ),
                    );
                  }
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Supervisor(ssn.toUpperCase())));
                }
              }
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Colors.red,
                  ),
                  actions: const [
                    Center(
                      child: Text("Wrong Password",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Icon(
                        Icons.error_outline_rounded,
                        size: 50,
                        color: Colors.red,
                      ),
                      actions: const [
                        Center(
                          child: Text("User Not Found",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ));
          }
        },
      );
    } else {
      Connection.conectivityDialog(context);
    }
  }

  Future<bool> _onBackPressed() async {
    return false;
  }

  String user = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 30, right: 30.0),
          child: Card(
            color: Colors.grey[100],
            elevation: 15,
            // color: Color.fromRGBO(32, 26, 92, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: AssetImage("images/Comsats.jpg"),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, top: 30.0),
                  child: Form(
                    // autovalidate: true,
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          autofocus: true,
                          controller: employeeId,
                          keyboardType: TextInputType.emailAddress,
                          validator: (str) {
                            if (str!.isEmpty) {
                              return "SSN is required";
                            } else {
                              bool student = RegExp(
                                      r"^(FA|SP)[0-9][0-9]-(BCS|MCS|BSE)-[0-9][0-9][0-9]$")
                                  .hasMatch(str.toUpperCase());
                              bool teacher =
                                  RegExp(r"^(VHR)(-)[0-9][0-9][0-9]$")
                                      .hasMatch(str.toUpperCase());
                              if (str.toLowerCase() == 'admin') {
                                user = "admin";
                              } else if (student) {
                                user = "student";
                              } else if (teacher) {
                                user = "faculty";
                              } else {
                                return "Invalid SSN Pattern";
                              }
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter SSN',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (str) {
                            if (str!.isNotEmpty && str.length < 4) {
                              return "Invalid Password";
                            } else if (str.isEmpty) {
                              return "Password is Required";
                            }
                          },
                          controller: employeePin,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            labelText: 'Password',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () {
                      final forgot = TextEditingController();
                      final forgotkey = GlobalKey<FormState>();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text("Forgot Password"),
                                elevation: 0.9,
                                content: SizedBox(
                                  height: 140.0,
                                  child: Column(
                                    children: [
                                      Form(
                                        key: forgotkey,
                                        child: TextFormField(
                                          autofocus: true,
                                          controller: forgot,
                                          autovalidate: true,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (str) {
                                            if (str!.isEmpty) {
                                              return "SSN is required";
                                            } else {
                                              bool student = RegExp(
                                                      r"^(FA|SP)[0-9][0-9]-(BCS|MCS|BSE)-[0-9][0-9][0-9]$")
                                                  .hasMatch(str.toUpperCase());
                                              bool teacher = RegExp(
                                                      r"^(VHR)(-)[0-9][0-9][0-9]$")
                                                  .hasMatch(str.toUpperCase());
                                              if (str.toLowerCase() ==
                                                  'admin') {
                                                resetUser = "admin";
                                              } else if (student) {
                                                resetUser = "student";
                                              } else if (teacher) {
                                                resetUser = "faculty";
                                              } else {
                                                return "Invalid SSN Pattern";
                                              }
                                            }
                                          },
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                            labelStyle:
                                                TextStyle(color: Colors.blue),
                                            border: OutlineInputBorder(),
                                            labelText: 'SSN',
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            final st = forgotkey.currentState;
                                            if (st!.validate()) {
                                              PasswordReset.reset(
                                                  _scaffoldKey.currentContext
                                                      as BuildContext,
                                                  forgot.text,
                                                  resetUser);
                                            }
                                          },
                                          child: Text("Send Email"))
                                    ],
                                  ),
                                ));
                          });
                    },
                    child: Text(
                      "Forget Password",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    focusNode: buttonfocus,
                    // textColor: Colors.white,
                    // color: Colors.blue,
                    child: Text('Login'),
                    onPressed: () async {
                      var abc = _formKey.currentState;

                      if (abc!.validate()) {
                        checkStatus(
                            employeeId.text.toString(), user, employeePin.text);
                        showDialog(
                          barrierDismissible: false,
                          useSafeArea: true,
                          context: context,
                          builder: (context) {
                            return WillPopScope(
                              onWillPop: _onBackPressed,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        );
                        abc.reset();
                      } else {
                        Connection.conectivityDialog(context);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
