// ignore_for_file: prefer_const_constructors, deprecated_member_use, empty_catches

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'connection.dart';
import 'email.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final employeeId = TextEditingController();
  final employeePin = TextEditingController();
  final FocusNode buttonfocus = FocusNode();

  void checkStatus(String s) async {
    var ref = FirebaseDatabase.instance.reference().child("users/student");
    await ref.once().then((value) {
      if (value.value[s.toUpperCase().toString()]["status"].toString() == '0') {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => Email(employeeId.text)));
      } else if (value.value[s.toUpperCase().toString()]["status"].toString() ==
          '1') {
        print("Value is 1");
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
    });
  }

  Future<void> signin(String email, String password) async {
    // ignore: unused_local_variable
    String usertype = "";
    bool conection = await Connection.tryConnection();
    if (conection) {
      try {
        // ignore: unused_local_variable
        UserCredential credentials = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        var user = credentials.user;

        var db =
            FirebaseDatabase.instance.reference().child("users/${user!.uid}");
        db.once().then((value) {
          if (value.value["isAdmin"].toString() == "true") {
            //  _formKey.currentState!.reset();
            Navigator.pop(context);
            buttonfocus.requestFocus();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => Admin()));
          } else {
            //   _formKey.currentState!.reset();
            Navigator.pop(context);
            buttonfocus.requestFocus();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => Home()));
          }
        });
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'user-not-found') {
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
        } else if (e.code == 'wrong-password') {
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
                  ));
        } else if (e.code == 'operation-not-allowed') {
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
                  child: Text("Email Password Authentication Disabled",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      }
    } else {
      Navigator.pop(context);
      Connection.conectivityDialog(context);
    }
  }

  Future<bool> _onBackPressed() async {
    return false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 150, left: 30, right: 30.0),
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
                  backgroundImage: AssetImage("images/Comsats.jpeg"),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 30.0),
                child: Form(
                  // autovalidate: true,
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: employeeId,
                        keyboardType: TextInputType.emailAddress,
                        validator: (str) {
                          if (str!.isEmpty) {
                            return "SSN is required";
                          } else {
                            bool emailValid = RegExp(
                                    r"^(FA|SP)[0-9][0-9]-(BCS|MCS|BSE)-[0-9][0-9][0-9]$")
                                .hasMatch(str);
                            if (!emailValid) {
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
                        keyboardType: TextInputType.visiblePassword,
                        validator: (str) {
                          if (str!.isNotEmpty && str.length < 6) {
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
                                            return "Email is required";
                                          } else {
                                            bool emailValid = RegExp(
                                                    r"^[A-za-z]+[@](cuivehari|ciitvehari).edu.pk$")
                                                .hasMatch(str);
                                            if (!emailValid) {
                                              return "Invalid Email Pattern";
                                            }
                                          }
                                        },
                                        style: TextStyle(color: Colors.black),
                                        decoration: InputDecoration(
                                          labelStyle:
                                              TextStyle(color: Colors.blue),
                                          border: OutlineInputBorder(),
                                          labelText: 'Email Address',
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          final st = forgotkey.currentState;
                                          if (st!.validate()) {
                                            await auth.sendPasswordResetEmail(
                                                email: forgot.text);
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
                      checkStatus(employeeId.text.toString());
                      // showDialog(
                      //   barrierDismissible: false,
                      //   useSafeArea: true,
                      //   context: context,
                      //   builder: (context) {
                      //     return WillPopScope(
                      //       onWillPop: _onBackPressed,
                      //       child: Center(child: CircularProgressIndicator()),
                      //     );
                      //   },
                      // );

                      // await signin(employeeId.text.toString(),
                      //     employeePin.text.toString());
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
    );
  }
}
