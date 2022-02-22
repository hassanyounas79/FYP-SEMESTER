// ignore_for_file: deprecated_member_use, avoid_print, non_constant_identifier_names, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OTP {
  static late int otp;
  static final _OtpKey = GlobalKey<FormState>();
  static late TextEditingController otpcontroler;
  static Future<bool> otpDilog(BuildContext context, String path) async {
    otpcontroler = TextEditingController();
    bool valid = false;
    Navigator.pop(context);
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter Your OTP"),
            content: SizedBox(
              height: 170,
              child: Column(children: [
                Form(
                  key: _OtpKey,
                  autovalidate: true,
                  child: TextFormField(
                    controller: otpcontroler,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter OTP',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value.length != 4) {
                        return "Invalid OTP";
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    child: Text('OK'),
                    onPressed: () async {
                      var state = _OtpKey.currentState;

                      if (state!.validate()) {
                        valid = await OTP.validateOtp(
                          otpcontroler.text,
                          context,
                          path,
                        );
                        if (valid) {
                          Navigator.pop(context);
                          otpcontroler.text = "";
                          valid = true;
                        }
                      }
                    },
                  ),
                ),
              ]),
            ),
          );
        });

    return valid;
  }

  static Future<bool> sendEmail(
      BuildContext context, String email, String path) async {
    bool valid = false;
    otp = Random().nextInt(8999) + 1000;
    String username = 'rehman0737266@gmail.com';
    String password = 'rehman@786123';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'FYP CIIT-VEHARI')
      ..recipients.add(email)
      ..subject = 'FYP Email Authentication'
      ..text = 'Please veify your Email Address using OTP \n Your OTP is: $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      print(otp);
      valid = await otpDilog(context, path);
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    var connection = PersistentConnection(smtpServer);
    await connection.close();
    return valid;
  }

  static Future<bool> validateOtp(
      String userOtp, BuildContext con, String path) {
    var intOtp = int.parse(userOtp);
    if (intOtp == otp) {
      // var ref = FirebaseDatabase.instance.reference().child(path);
      // ref.update({"status": 1});

      return Future(() => true);
    } else {
      showDialog(
        context: con,
        builder: (BuildContext context) => const AlertDialog(
          title: Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: Colors.red,
          ),
          actions: [
            Center(
              child: Text("Your Entered OTP is Incorrect",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return Future(() => false);
    }
  }
}
