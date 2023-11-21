import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_sample/add_data.dart';
import 'package:flutter_firebase_sample/alldata.dart';
import 'package:flutter_firebase_sample/authenticator.dart';
import 'package:flutter_firebase_sample/login.dart';
import 'package:flutter_firebase_sample/page1.dart';
import 'package:flutter_firebase_sample/register.dart';
import 'package:flutter_firebase_sample/update_data.dart';
import 'package:flutter_firebase_sample/updatephoto.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Alldata(),
    );
  }
}
