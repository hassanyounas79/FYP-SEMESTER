import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Connection {
  static Future<bool> tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      return response.isNotEmpty;
    } on SocketException catch (e) {
      return false;
    }
  }

  static void conectivityDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: SizedBox(
              height: 80,
              child: Column(
                children: const [
                  Icon(
                    Icons.error_outline_sharp,
                    size: 50,
                  ),
                  Text("No Internet Access"),
                ],
              ),
            ),
          );
        });
  }
}
