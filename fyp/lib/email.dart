// ignore_for_file: prefer_const_constructors, must_be_immutable, no_logic_in_create_state, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fyp/otp.dart';

class Email extends StatefulWidget {
  String registraion;
  Email(this.registraion, {Key? key}) : super(key: key);

  @override
  _EmailState createState() => _EmailState(registraion);
}

class _EmailState extends State<Email> {
  _EmailState(this.registraion);
  late String registraion;
  final _formKey = GlobalKey<FormState>();
  final _OtpKey = GlobalKey<FormState>();
  final emailcontroler = TextEditingController();
  final otpcontroler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  backgroundImage: AssetImage("images/Comsats.jpeg"),
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
                            await OTP.sendEmail(emailcontroler.text);
                            Navigator.pop(context);
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Enter Your OTP"),
                                    content: SizedBox(
                                      height: 170,
                                      child: Column(children: [
                                        Form(
                                          key: _OtpKey,
                                          autovalidate: true,
                                          child: TextFormField(
                                            controller: otpcontroler,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Enter OTP',
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty ||
                                                  value.length != 4) {
                                                return "Invalid OTP";
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: ElevatedButton(
                                            child: Text('OK'),
                                            onPressed: () async {
                                              var state = _OtpKey.currentState;

                                              if (state!.validate()) {
                                                bool valid = OTP.validateOtp(
                                                    registraion,
                                                    otpcontroler.text,
                                                    context);
                                                if (valid) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ]),
                                    ),
                                  );
                                });
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
