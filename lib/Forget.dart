import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetScreen extends StatefulWidget {
  @override
  _ForgetScreenState createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen>
    with SingleTickerProviderStateMixin {
  late String email;
  bool showProgress = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Icon(
                CupertinoIcons.lock,
                size: 120,
              ),
              SizedBox(height: 20),
              Text(
                'Reset Password',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 10),
              Text('Insert Your Email to Reset Your Password'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Form(key: formKey,
                  child: CupertinoFormSection(
                    children: [
                      CupertinoTextFormFieldRow(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.black.withOpacity(.3),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        placeholder: 'Enter Your Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains("@")||!value.contains(".com")) {
                            return 'Email must contain "@ and com"';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            email = value.trim();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoButton.filled(
                child: Text('Reset Password'),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: email,
                      );
                      showLoginStatusDialog("Email Sent! Please Check Your Email and Reset Your Password", success: true);
                    } on FirebaseAuthException catch (e) {
                      showLoginStatusDialog(e.message.toString(), success: false);
                    }

                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void showLoginStatusDialog(String message, {bool success = false}) {
    IconData iconData = success ? CupertinoIcons.check_mark : CupertinoIcons.xmark;
    Color iconColor = success ? CupertinoColors.systemGreen : CupertinoColors.systemRed;

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pop(context);

        });

        return CupertinoAlertDialog(
          title: Column(
            children: [
              Icon(
                iconData,
                color: iconColor,
              ),
              SizedBox(width: 8.0),
              Text("Reset Password"),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: CupertinoColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
