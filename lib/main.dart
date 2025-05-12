import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../app/controllers/db_services_controller.dart';
import '../app/models/user.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Set the status bar color globally before the app starts
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFFC0C78C), // Set your desired color here
    statusBarIconBrightness: Brightness.light, // For light icons on dark background
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  final DbServicesController firestore = Get.put(DbServicesController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: firestore.getUserDataLog(), // Fetch user data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return MaterialApp(
            home: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Handle error
          return MaterialApp(
            home: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // User data is available
          UserModel? user = snapshot.data;
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Application",
            initialRoute: user != null ? Routes.DASHBOARD : Routes.LOGIN,
            getPages: AppPages.routes,
          );
        }
      },
    );
  }
}