import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:io';

import 'home_page.dart';
import 'loginsignup/LoginScreen.dart';

late Size mq;

Map<String, List<String>> notificationMap = {};

FirebaseAuth auth = FirebaseAuth.instance;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Initializing Firebase...");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized successfully.");

  if (auth.currentUser != null) {
    runApp(home());
  } else {
    runApp(login());
  }
}

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue,
                // Set the app bar background color to grey[400]
                elevation: 0,
                // Set the app bar elevation to 0
                iconTheme: IconThemeData(color: Colors.white),
                // Set icon color to black
                titleTextStyle: TextStyle(
                  color: Colors.red,
                  // Set title text color to black
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  // Set title text to normal style
                  fontFamily: 'Pacifico',
                  letterSpacing: 3.0, // Set letter spacing for title text
                ),
                actionsIconTheme: IconThemeData(color: Colors.white),
                // Set action icon color to black
                shadowColor:
                Colors.transparent, // Set shadow color to transparent
                // Optionally, you can customize other properties like shape, toolbarTextStyle, etc.
              ),
              visualDensity: VisualDensity.standard,
            ),
            title: "dream",
            home: LoginScreen(),
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              final scale = mediaQueryData.copyWith(textScaleFactor: 1.0);
              child = MediaQuery(data: scale, child: child!);
              return child;
            },
          );
        });
  }
}

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue,
              // Set the app bar background color to grey[400]
              elevation: 0,
              // Set the app bar elevation to 0
              iconTheme: IconThemeData(color: Colors.white),
              // Set icon color to black
              titleTextStyle: TextStyle(
                color: Colors.white,
                // Set title text color to black
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                // Set title text to normal style
                fontFamily: 'RedditMono',
                letterSpacing: 3.0, // Set letter spacing for title text
              ),
              actionsIconTheme: IconThemeData(color: Colors.white),
              // Set action icon color to black
              shadowColor:
              Colors.transparent, // Set shadow color to transparent
              // Optionally, you can customize other properties like shape, toolbarTextStyle, etc.
            ),
            visualDensity: VisualDensity.standard,
          ),
          title: "dream",
          home: HomePage(),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.copyWith(textScaleFactor: 1.0);
            child = MediaQuery(data: scale, child: child!);
            return child;
          },
        );
      },
    );
  }
}
