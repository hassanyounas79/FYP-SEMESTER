// ignore_for_file: prefer_const_constructors, must_be_immutable, no_logic_in_create_state, deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fyp/firebase/firebase.dart';

import 'otp.dart';

class Email extends StatefulWidget {
  String ssn;
  String user;
  Email(this.ssn, this.user, {Key? key}) : super(key: key);

  @override
  _EmailState createState() => _EmailState(ssn, user);
}

class _EmailState extends State<Email> {
  _EmailState(this.ssn, this.user);
  String ssn;
  String user;
  final _formKey = GlobalKey<FormState>();
  final emailcontroler = TextEditingController();
  final otpcontroler = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 150, left: 30, right: 30.0),
        child: Card(
          elevation: 7,
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
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Plaese Verify your Email',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 30.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        autofocus: true,
                        controller: emailcontroler,
                        autovalidate: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email is required";
                          } else if (value.isNotEmpty) {
                            bool emailValid = RegExp(
                                    r"^\w+([-+.’]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
                                .hasMatch(value);
                            if (!emailValid) {
                              return "Invalid Email";
                            }
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email Address',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        child: Text('Verify'),
                        onPressed: () async {
                          final state = _formKey.currentState;
                          if (state!.validate()) {
                            otpcontroler.text = "";
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });
                            bool valid = await OTP.sendEmail(
                                context, emailcontroler.text, "");
                            if (valid) {
                              String path;
                              if (user == "admin") {
                                path = "users/admin";
                              } else if (user == "student") {
                                path = "users/student/${ssn.toUpperCase()}";
                              } else {
                                path = "users/faculty/${ssn.toUpperCase()}";
                              }

                              FirebaseCon.ref.reference().child(path).update(
                                  {'email': emailcontroler.text, 'status': 1});
                              //new password Dilog
                              final key = GlobalKey<FormState>();
                              final TextEditingController _pass =
                                  TextEditingController();
                              Navigator.pop(context);
                              showDialog(
                                  context: _scaffoldKey.currentContext
                                      as BuildContext,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.transparent,
                                      content: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          padding: EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Form(
                                            key: key,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15),
                                                    child: TextFormField(
                                                      controller: _pass,
                                                      autovalidateMode:
                                                          AutovalidateMode
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
                                                          label: Text(
                                                              'New Password'),
                                                          alignLabelWithHint:
                                                              true,
                                                          hintText:
                                                              "New Password",
                                                          border:
                                                              OutlineInputBorder()),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15),
                                                    child: TextFormField(
                                                      autovalidateMode:
                                                          AutovalidateMode
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
                                                          label: Text(
                                                              'Confirm Password'),
                                                          alignLabelWithHint:
                                                              true,
                                                          hintText:
                                                              'Confirm Password',
                                                          border:
                                                              OutlineInputBorder()),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    child: Center(
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          var state =
                                                              key.currentState;
                                                          if (state!
                                                              .validate()) {
                                                            await FirebaseCon
                                                                .ref
                                                                .reference()
                                                                .child(path)
                                                                .update({
                                                              'password':
                                                                  _pass.text
                                                            });
                                                          }
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          width: 120,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .blue[800]!,
                                                                Colors.purple[
                                                                    800]!
                                                              ],
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "Change",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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

                              //New Password Dilog
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
