// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:firebase_database/firebase_database.dart';

class OTP {
  static late int otp;
  static Future<void> sendEmail(String email) async {
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
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    var connection = PersistentConnection(smtpServer);
    await connection.close();
  }

  static bool validateOtp(String reg, String userOtp, BuildContext con) {
    var intOtp = int.parse(userOtp);
    if (intOtp == otp) {
      var ref =
          FirebaseDatabase.instance.reference().child("users/student/$reg");
      ref.update({"status": 1});
      return true;
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
      return false;
    }
  }
}
