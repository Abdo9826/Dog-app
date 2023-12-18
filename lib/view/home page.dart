import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:dogs_app/Login.dart';
import 'package:dogs_app/controller/const.dart';
import 'package:dogs_app/view/chat%20page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../Chat.dart';
import 'Setting.dart';

String imageurl = ''; // ImageProvider for the fetched image

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? paymentIntent;
  ImageProvider<Object>? imageProvider; // ImageProvider for the fetched image

  Future<void> fetchImage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    print(uid);
    var downloadUrl = await FirebaseStorage.instance
        .ref(
            'Dogs Images/${FirebaseAuth.instance.currentUser!.uid}') // Replace with your image path in Firebase Storage
        .getDownloadURL();

    setState(() {
      imageurl = downloadUrl;
      imageProvider = NetworkImage(downloadUrl);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);

    fetchImage();
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId()!,
      listener: (AdmobAdEvent event, Map<String, dynamic>? args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );
    interstitialAd.load();
    Timer(Duration(seconds: 5), () {
      interstitialAd.show();
    });
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic>? args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: scaffoldState.currentContext!,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                return true;
              },
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args!['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
            );
          },
        );
        break;
      default:
    }
  }

  void showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  String? getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return '';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    return null;
  }

  late PageController _pageController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _currentPageIndex = 0;

  late AdmobInterstitial interstitialAd;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  double width = 0;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldState,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemCount: _getPageCount(),
        itemBuilder: (context, index) {
          return buildPage(index);
        },
      ),

      // bottom Sections
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple.shade700,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentPageIndex,
        onTap: changeIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Heart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _currentIndex = 0;

  int _getPageCount() {
    // Return the total number of pages in the PageView
    return 4; // Adjust this based on your number of tabs
  }

  Widget buildPage(int index) {
    switch (index) {
      case 0: // Home tab
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        // Adjust the width and height as per your requirement
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider ??
                                AssetImage('assets/images/3.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // icon

                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.black,
                          ),

                          // name

                          Text(
                            "Denver",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),

                      // Notifications icon
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 30.0,
                          ))
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: AdmobBanner(
                      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
                      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
                        width: MediaQuery.of(context).size.width.toInt(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 42.0),

                  // Page main photo

                  Stack(
                    children: [
                      // Dogs Images

                      Container(
                        width: width,
                        height: height * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32.0),
                          image: DecorationImage(
                              image: AssetImage('assets/images/5.jpg'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 9.0,
                        right: 18.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Text and lighting icon

                            Container(
                              width: width * 0.5,
                              height: height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.electric_bolt_sharp,
                                    color: Colors.yellowAccent,
                                  ),
                                  Text(
                                    "Potential match",
                                    style: TextStyle(fontSize: 17.5),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12.0),

                            // How mach is far Text

                            Container(
                              width: width * 0.2,
                              height: height * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.5),
                                color: Colors.deepPurple.shade700,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    "12 Km",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom text (name, age, Descriptions)

                      Positioned(
                        bottom: 12.0,
                        left: 25.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text Name and Age
                            const Text(
                              "Francesco, 2 years",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23.0),
                            ),

                            const SizedBox(height: 3.0),

                            // Text Description
                            Text(
                              "i will be genital and passionate with my girl",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16.0,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 25.0),

                  // Buttons

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dogs icon

                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.purple.shade700,
                                width: 4,
                                style: BorderStyle.solid),
                            color: Colors.red),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40.0,
                          child: Center(
                            child: Text(
                              "🐕",
                              style: TextStyle(fontSize: 26.0),
                            ),
                          ),
                        ),
                      ),

                      // Bons Icon

                      CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade700,
                        radius: 40.0,
                        child: const Center(
                          child: Text(
                            "🦴",
                            style: TextStyle(fontSize: 26.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ); // Replace with your HomeTabPage widget
      case 1: // Heart tab
        return Column(
          children: [Text("2")],
        ); // Replace with your HeartTabPage widget
      case 2: // Messages tab
        return ChatListScreen(
            uiddd: '',
            image: imageurl); // Replace with your HeartTabPage widget
      case 3: // Settings tab
        return SettingsPage(); // Replace with your HeartTabPage widget
      default:
        return Column(
          children: [Text("4")],
        ); // Replace with your HeartTabPage widget
    }
  }

  void changeIndex(int index) {
    setState(() {
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
      _currentPageIndex = index;
    });
  }
//
// Future<void> makePayment() async {
//   try {
//     paymentIntent = await createPaymentIntent('2', 'CAD');
//     await Stripe.instance
//         .initPaymentSheet(
//             paymentSheetParameters: SetupPaymentSheetParameters(
//                 paymentIntentClientSecret: paymentIntent![
//                     'client_secret'], //Gotten from payment intent
//                 merchantDisplayName: 'Dating Dog'))
//         .then((value) {});
//
//     //STEP 3: Display Payment sheet
//     displayPaymentSheet();
//   } catch (err) {
//     throw Exception(err);
//   }
// }
//
// displayPaymentSheet() async {
//   try {
//     await Stripe.instance.presentPaymentSheet().then((value) {
//       showDialog(
//           useSafeArea: true,
//           useRootNavigator: false,
//           barrierDismissible: false,
//           context: context,
//           builder: (_) => AlertDialog(
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                       size: 100.0,
//                     ),
//                     SizedBox(height: 10.0),
//                     Text("Payment Successful!"),
//                   ],
//                 ),
//               ));
//
//       paymentIntent = null;
//     }).onError((error, stackTrace) {
//       throw Exception(error);
//     });
//   } on StripeException catch (e) {
//     AlertDialog(
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: const [
//               Icon(
//                 Icons.cancel,
//                 color: Colors.red,
//               ),
//               Text("Payment Failed"),
//             ],
//           ),
//         ],
//       ),
//     );
//   } catch (e) {}
// }
//
// createPaymentIntent(String amount, String currency) async {
//   try {
//     //Request body
//     Map<String, dynamic> body = {
//       'amount': calculateAmount(amount),
//       'currency': currency,
//     };
//
//     //Make post request to Stripe
//     var response = await http.post(
//       Uri.parse('https://api.stripe.com/v1/payment_intents'),
//       headers: {
//         'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
//         'Content-Type': 'application/x-www-form-urlencoded'
//       },
//       body: body,
//     );
//     return json.decode(response.body);
//   } catch (err) {
//     throw Exception(err.toString());
//   }
// }
//
// calculateAmount(String amount) {
//   final calculatedAmout = (int.parse(amount)) * 100;
//   return calculatedAmout.toString();
// }
}

class AccountSettingsPage extends StatefulWidget {
  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'), // Title for the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Perform user logout on IconButton press
              await FirebaseAuth.instance.signOut();
              // Navigate to the LoginScreen after logout
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: user != null
              ? Column(
                  // Display user information if user is logged in
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(user.photoURL ?? ''),
                      // Display user's profile image in a CircleAvatar or use a placeholder icon
                      // child: Icon(Icons.person), // Placeholder icon
                    ),
                    SizedBox(height: 20),
                    Text(
                      user.displayName ?? 'No Name',
                      // Display user's name or placeholder
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      user.email ??
                          'No Email', // Display user's email or placeholder
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Implement forgot password functionality when button is pressed
                        _forgotPassword(context, user.email!);
                      },
                      child: Text('Forgot Password'), // Button text
                    ),
                  ],
                )
              : CircularProgressIndicator(), // Display a loading indicator while user info is loading
        ),
      ),
    );
  }

  void _forgotPassword(BuildContext context, String email) {
    // Send password reset email to the provided email address
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // Show a snackbar to inform the user that the reset link has been sent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset link sent to $email'),
      ),
    );
  }
}
