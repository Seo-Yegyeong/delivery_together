import 'package:cloud_firestore/cloud_firestore.dart';
import 'Authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Delivery Together',
      theme: ThemeData(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Color(0xFF284463),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF284463),
          // toolbarHeight: getScreenHeight(context) * 0.2
        ),
      ),
      // home: Home(),
      initialRoute: '/auth',
      routes: {
        '/auth': (BuildContext context) => const Authentication(),
      },
    );
  }
}
