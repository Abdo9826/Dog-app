import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_app/view/home%20page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'Forget.dart';
import 'Signup.dart';
import 'controller/const.dart';
import 'controller/functions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late String email, password;
  bool hidePassword = true;
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  final linked = Get.put(DogsImage());
  final linked2 = Get.lazyPut(() => DogsAccountInfo());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
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
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      DogsCardCarousel(images: [
                        DecorationImage(
                            image: linked.image1, fit: BoxFit.cover),
                        DecorationImage(
                            image: linked.image2, fit: BoxFit.cover),
                        DecorationImage(
                            image: linked.image3, fit: BoxFit.cover),
                        DecorationImage(
                            image: linked.image4, fit: BoxFit.cover),
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      DogsCardCarousel1(images: [
                        DecorationImage(
                            image: linked.image5, fit: BoxFit.cover),
                        DecorationImage(
                            image: linked.image6, fit: BoxFit.cover),
                        DecorationImage(
                            image: linked.image7, fit: BoxFit.cover),
                        DecorationImage(image: linked.image8, fit: BoxFit.cover)
                      ])
                    ],
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                    child: Text(
                      "Log In\nto Meet Your Friends.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.2, 10.0),
                            blurRadius: 70.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: Validators.compose([
                              Validators.required('Email is required'),
                              Validators.email('Invalid email address'),
                            ]),
                            onChanged: (value) {
                              email = value.trim(); // Get value from TextField
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                CupertinoIcons.mail,
                                color: Color(0xff000000),
                              ),
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              // Hint text style
                              filled: true,
                              fillColor: Colors.grey[200],
                              // Field color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    color: Color(0xffe200fd), width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              if (value.trim().length < 7) {
                                return 'Password must be at least 7 characters';
                              }
                              // Return null if the entered password is valid
                              return null;
                            },
                            obscureText: hidePassword,
                            onChanged: (value) {
                              password = value.trim(); // Get value from TextField
                            },
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              // Hint text style
                              filled: true,
                              fillColor: Colors.grey[200],
                              // Field color
                              prefixIcon: Icon(
                                CupertinoIcons.padlock,
                                color: Colors.black,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  hidePassword = !hidePassword;
                                  setState(() {});
                                },
                                child: hidePassword
                                    ? const Icon(Icons.visibility,
                                        color: Colors.blue)
                                    : const Icon(Icons.visibility_off,
                                        color: Color(0xff153b4f)),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    color: Color(0xffe200fd), width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ForgetScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB2B2B2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.red,
                      onTap: () async {
                        if (formKey.currentState?.validate() == true) {
                          showCircularProgressDialog(context);
                          try {
                            final newuser =
                                await _auth.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            if (newuser != null) {
                              // Close the circular progress dialog
                              Navigator.pop(context);

                              showLoginStatusDialog("Logged in successfully",
                                  success: true);
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                              formKey.currentState?.reset();
                            } else {
                              // Close the circular progress dialog
                              Navigator.pop(context);

                              showLoginStatusDialog("Error");
                            }
                          } on FirebaseAuthException catch (e) {
                            // Close the circular progress dialog
                            Navigator.pop(context);

                            if (e.code == 'wrong-password') {
                              showLoginStatusDialog(
                                  'Wrong password. Please try again.');
                            } else if (e.code == 'user-not-found') {
                              showLoginStatusDialog(
                                  'User not found. Please sign up.');
                            } else {
                              showLoginStatusDialog(e.code);
                            }
                          } catch (e) {
                            // Close the circular progress dialog
                            Navigator.pop(context);

                            showLoginStatusDialog(e.toString());
                          }
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: const AssetImage('assets/images/bg.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.7),
                              BlendMode.dstATop,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Continue',
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
                  const Padding(padding: EdgeInsets.all(5
                  )),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: "Don't have an account yet ? ",
                          style: TextStyle(
                              color: CupertinoColors.black.withOpacity(.5))),
                      TextSpan(
                        text: 'Create Now',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => Signup(),
                              ),
                            );
                          },
                        style:
                            const TextStyle(color: CupertinoColors.systemBlue),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // RichText(
                  //   text: TextSpan(children: [
                  //     TextSpan(
                  //         text: "Or Sign in Using Google",
                  //         style: TextStyle(
                  //             color: CupertinoColors.black.withOpacity(.5))),
                  //   ]),
                  // ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         signInWithGoogle( context: context);
                  //       },
                  //       child: Container(
                  //         width: 80,
                  //         padding: EdgeInsets.all(10.0),
                  //         decoration: BoxDecoration(
                  //           color: CupertinoColors.white,
                  //           border: Border.all(
                  //             color: CupertinoColors.black,
                  //             width: 1.0,
                  //           ),
                  //           borderRadius: BorderRadius.circular(8.0),
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: <Widget>[
                  //             Image.asset(
                  //               "assets/images/google.png",
                  //               scale: 13,
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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

  void showLoginStatusDialog(String message, {bool success = false}) {
    IconData iconData =
        success ? CupertinoIcons.check_mark : CupertinoIcons.xmark;
    Color iconColor =
        success ? CupertinoColors.systemGreen : CupertinoColors.systemRed;

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Timer(Duration(seconds: 2), () {
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
              Text("Login Status"),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: CupertinoColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          // actions: <Widget>[
          //   CupertinoDialogAction(
          //     child: Text("OK"),
          //     onPressed: () {
          //       Navigator.pop(context); // Close the dialog
          //       if (success) {
          //         // Reset the form or navigate to another page on success
          //         formKey.currentState?.reset();
          //       }
          //     },
          //   ),
          // ],
        );
      },
    );
  }
}

class DogsCardCarousel extends StatefulWidget {
  final List<DecorationImage> images;

  const DogsCardCarousel({Key? key, required this.images}) : super(key: key);

  @override
  _DogsCardCarouselState createState() => _DogsCardCarouselState();
}

class _DogsCardCarouselState extends State<DogsCardCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      viewportFraction: 0.45, // Adjust this value to change image spacing
    );

    _animateCarousel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateCarousel() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentPage < widget.images.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _animateCarousel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.17,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          double scale = 1;
          if (_pageController.position.haveDimensions) {
            scale = 1 - ((_currentPage - index).abs() * 0.3);
          }
          return Center(
            child: SizedBox(
              height: Curves.easeInOut.transform(scale) * 300,
              width: Curves.easeInOut.transform(scale) * 500,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                child: DogsCard(image: widget.images[index]),
              ),
            ),
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }
}

class DogsCardCarousel1 extends StatefulWidget {
  final List<DecorationImage> images;

  const DogsCardCarousel1({Key? key, required this.images}) : super(key: key);

  @override
  _DogsCardCarouselState1 createState() => _DogsCardCarouselState1();
}

class _DogsCardCarouselState1 extends State<DogsCardCarousel1> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.45, // Adjust this value to change image spacing
    );

    _animateCarousel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateCarousel() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentPage < widget.images.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _animateCarousel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.17,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              double scale = 1;
              if (_pageController.position.haveDimensions) {
                scale = 1 - ((_currentPage - index).abs() * 0.3);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeInOut.transform(scale) * 300,
                  width: Curves.easeInOut.transform(scale) * 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 5),
                    child: DogsCard(image: widget.images[index]),
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
      ],
    );
  }




}
//
// Future<User?> signInWithGoogle({required BuildContext context}) async {
//   FirebaseAuth auth = FirebaseAuth.instance;
//   User? user;
//
//   if (kIsWeb) {
//     GoogleAuthProvider authProvider = GoogleAuthProvider();
//
//     try {
//       final UserCredential userCredential =
//       await auth.signInWithPopup(authProvider);
//
//       user = userCredential.user;
//     } catch (e) {
//       print(e);
//     }
//   } else {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//
//     final GoogleSignInAccount? googleSignInAccount =
//     await googleSignIn.signIn();
//
//     if (googleSignInAccount != null) {
//       final GoogleSignInAuthentication googleSignInAuthentication =
//       await googleSignInAccount.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//
//       try {
//         final UserCredential userCredential =
//         await auth.signInWithCredential(credential);
//
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomePage()));
//       } on FirebaseAuthException catch (e) {final snackBar = SnackBar(
//         behavior: SnackBarBehavior.floating,
//         dismissDirection: DismissDirection.down,
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline),
//             SizedBox(
//               width: 200,
//               child: Text(
//                 e.code,
//                 style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w400),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF68B1D2),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       if (e.code == 'account-exists-with-different-credential') {
//         // ...
//       } else if (e.code == 'invalid-credential') {
//         // ...
//       }
//       } catch (e) {
//         // ...
//       }
//     }
//   }
//
//   return user;
// }