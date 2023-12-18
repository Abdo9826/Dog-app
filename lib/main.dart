import 'package:admob_flutter/admob_flutter.dart';
import 'package:dogs_app/view/opening%20page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'Auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  "Your Key";
  await dotenv.load(fileName: "assets/.env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );   Admob.initialize();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dogs dating app",
      home: AuthenticationWrapper(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OpeningPage(),
    );
  }
}
