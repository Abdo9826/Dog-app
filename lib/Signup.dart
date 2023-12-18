import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_app/view/home%20page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'Login.dart';
import 'controller/const.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  late String email, number, password, address, confirmPassword, fname, lname;
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool hidePassword1 = true;

  void showCircularProgressDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _lights = 0;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  late String uid;

  Future<void> addUser() {
    uid = FirebaseAuth.instance.currentUser!.uid.toString();
    // uploadImageToFirebase();
    return users
        .doc(uid)
        .set({
          'DogName': fname.trim(),
          'email': email.trim(),
          'uid': uid,
          'Dog Image': downloadURL,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  late String downloadURL;
  final linked = Get.put(DogsImage());
  final linked2 = Get.lazyPut(() => DogsAccountInfo());
  File? _image; // Declare _image as a class-level variable
  Future uploadImageToFirebase() async {
    try {
      if (_image != null) {
        Reference ref =
            FirebaseStorage.instance.ref().child('Dogs Images').child(uid);

        await ref.putFile(_image!).whenComplete(() {});
        downloadURL = await ref.getDownloadURL();

        print('File uploaded. Download URL: $downloadURL');
      }
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Widget buildImageOrLottie() {
    if (_image != null) {
      return Image.file(
        _image!,
        height: 120,
        width: 120,
        fit: BoxFit.fitHeight,
      );
    } else {
      return Column(
        children: [
          Transform.scale(
            scale: 1.8,
            // Adjust the scale factor as needed
            child: Lottie.asset(
              'assets/Animation/dog.json',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8.0,
            child: GestureDetector(
              onTap: getImage,
              child: Text("Pick Image"),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade300,
                Colors.deepPurple.shade500,
              ],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    DogsCardCarousel(images: [
                      DecorationImage(image: linked.image1, fit: BoxFit.cover),
                      DecorationImage(image: linked.image2, fit: BoxFit.cover),
                      DecorationImage(image: linked.image3, fit: BoxFit.cover),
                      DecorationImage(image: linked.image4, fit: BoxFit.cover),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    DogsCardCarousel1(images: [
                      DecorationImage(image: linked.image5, fit: BoxFit.cover),
                      DecorationImage(image: linked.image6, fit: BoxFit.cover),
                      DecorationImage(image: linked.image7, fit: BoxFit.cover),
                      DecorationImage(image: linked.image8, fit: BoxFit.cover)
                    ])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                            ),
                            Container(
                              height: 160,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.pets_outlined,
                                        color: Colors.redAccent,
                                        size: 40,
                                      ),
                                      Text(
                                        "Create Your\nNew Account",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(1.2, 10.0),
                                              blurRadius: 70.0,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: TextFormField(
                                          keyboardType: TextInputType.name,

                                          validator: Validators.compose([
                                            Validators.required(
                                                'Name is required'),
                                          ]),
                                          onChanged: (value) {
                                            fname = value.trim();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Roxy',
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                  color: Color(0xffe200fd),
                                                  width: 1.5),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.pets,
                                              color: Colors.black,
                                            ),
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: Container(
                                        height: 140,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (_image != null)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.file(
                                                  _image!,
                                                  height: 140,
                                                  width: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            else
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Transform.scale(
                                                    scale: 1.8,
                                                    // Adjust the scale factor as needed
                                                    child: Lottie.asset(
                                                      'assets/Animation/dog.json',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Pick Image",
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .white),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: TextFormField(
                                validator: Validators.compose([
                                  Validators.required('Email is required'),
                                  Validators.email('Invalid email address'),
                                ]),
                                onChanged: (value) {
                                  email = value.trim(); // get value from TextField
                                },
                                keyboardType: TextInputType.emailAddress,

                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Color(0xffe200fd), width: 1.5),
                                  ),
                                  prefixIcon: Icon(
                                    CupertinoIcons.mail_solid,
                                    color: Colors.black,
                                  ),
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                ),
                              ),
                            ),
                            Stack(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.trim().length < 7) {
                                      return 'Password must be at least 7 characters';
                                    }
                                    if (value != confirmPassword) {
                                      return 'Passwords doe not match';
                                    }
                                    // Return null if the entered password is valid
                                    return null;
                                  },
                                  keyboardType: TextInputType.visiblePassword,

                                  onChanged: (value) {
                                    password =
                                        value.trim(); // get value from TextField
                                  },
                                  obscureText: hidePassword1,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Color(0xffe200fd), width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      CupertinoIcons.padlock,
                                      color: Colors.black,
                                    ),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          hidePassword1 = !hidePassword1;
                                        });
                                      },
                                      child: Icon(
                                        hidePassword1
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Stack(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.visiblePassword,

                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Confirm Password is required';
                                    }
                                    if (value != password) {
                                      return 'Passwords does not match';
                                    }
                                    // Return null if the entered password is valid
                                    return null;
                                  },
                                  onChanged: (value) {
                                    confirmPassword =
                                        value.trim(); // get value from TextField
                                  },
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Color(0xffe200fd), width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      CupertinoIcons.padlock_solid,
                                      color: Colors.black,
                                    ),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                      child: Icon(
                                        hidePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.red,
                                onTap: () async {
                                  if (_formKey.currentState?.validate() ==
                                      true) {
                                    showCircularProgressDialog(context);

                                    try {
                                      final newuser = await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: email, password: password);
                                      if (_image != null) {
                                        Reference ref = FirebaseStorage.instance
                                            .ref()
                                            .child('Dogs Images')
                                            .child(newuser.user!.uid);

                                        await ref
                                            .putFile(_image!)
                                            .whenComplete(() async {
                                          Navigator.pop(context);

                                          downloadURL =
                                              await ref.getDownloadURL();

                                          if (newuser != null) {
                                            showRegistrationStatusDialog(
                                                "Registered successfully",
                                                success: true);
                                            addUser();
                                            _formKey.currentState?.reset();
                                            downloadURL = '';
                                            _image = null;
                                          } else {
                                            showRegistrationStatusDialog(
                                                "Error");
                                          }
                                        });
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'email-already-in-use') {
                                        showRegistrationStatusDialog(
                                            'The account already exists for that email.');
                                      } else {
                                        showRegistrationStatusDialog(e.code);
                                      }
                                    } catch (e) {
                                      showRegistrationStatusDialog(
                                          e.toString());
                                    }
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: const AssetImage(
                                          'assets/images/bg.png'),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.7),
                                        BlendMode.dstATop,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Already have an Account? ",
                                    style: TextStyle(
                                        color: CupertinoColors.black
                                            .withOpacity(.5))),
                                TextSpan(
                                  text: 'Login Now!',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pop(context);
                                    },
                                  style: const TextStyle(
                                      color: CupertinoColors.systemBlue),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showRegistrationStatusDialog(String message, {bool success = false}) {
    IconData iconData =
        success ? CupertinoIcons.check_mark : CupertinoIcons.xmark;
    Color iconColor =
        success ? CupertinoColors.systemGreen : CupertinoColors.systemRed;

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Column(
            children: [
              Icon(
                iconData,
                color: iconColor,
              ),
              SizedBox(width: 8.0),
              Text("Registration Status"),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: CupertinoColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Continue"),
              onPressed: () {
                success
                    ? Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      )
                    : Navigator.pop(context);
                if (success) {
                  _formKey.currentState?.reset();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
