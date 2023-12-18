import 'package:dogs_app/view/home%20page.dart';
import 'package:dogs_app/view/opening%20page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthenticationWrapper extends StatefulWidget {
  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      navigateToScreen();
    });
  }

  void navigateToScreen() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => OpeningPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              'assets/Animation/loading.json',
            ),
          ],
        ),
      ),
    );
  }
}
