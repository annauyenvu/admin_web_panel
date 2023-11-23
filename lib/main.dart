import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyByupk_LXb0kN_Z1vTEi4be1ug8xb53zac",
        authDomain: "taxi-dispatch-21caf.firebaseapp.com",
        databaseURL: "https://taxi-dispatch-21caf-default-rtdb.firebaseio.com",
        projectId: "taxi-dispatch-21caf",
        storageBucket: "taxi-dispatch-21caf.appspot.com",
        messagingSenderId: "1066026920128",
        appId: "1:1066026920128:web:73b92de854b20f91ae2525",
        measurementId: "G-0WKJ1W5292"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SideNavigationDrawer(),
    );
  }
}

