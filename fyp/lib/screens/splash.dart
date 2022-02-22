// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:flutter/material.dart';

import 'login.dart';

class Splash extends StatefulWidget {
  //const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _mainPage();
  }

  _mainPage() async {
    await Future.delayed(
      const Duration(milliseconds: 2900),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(children: const [
          Expanded(
            flex: 10,
            child: Image(
              height: 200,
              width: 200,
              image: AssetImage("images/splash.png"),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              "Powered By:RSoft",
              style: TextStyle(
                  color: Color.fromRGBO(35, 4, 59, 1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }
}
