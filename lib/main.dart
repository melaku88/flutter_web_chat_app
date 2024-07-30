import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/colors/default_colors.dart';
import 'package:flutter_web_chat_app/provider/provider_chat.dart';
import 'package:flutter_web_chat_app/routes/routes_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

String initialPage = '/';

void main() async{
  await Firebase.initializeApp(options: FirebaseOptions(
    apiKey: "AIzaSyAwzPV0oa2lEewG3sZpksc66Pv4xIumfYg",
    authDomain: "web-chat-app-1bf28.firebaseapp.com",
    projectId: "web-chat-app-1bf28",
    storageBucket: "web-chat-app-1bf28.appspot.com",
    messagingSenderId: "1099162387964",
    appId: "1:1099162387964:web:5a5818c9862631cc105e79",
    measurementId: "G-EQK6J6F4RD"
  ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProviderChat(),
      child: MyApp(),
    )
  );
}

final ThemeData defaultThemeForWebApp = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: DefaultColors.primary),
  textTheme: GoogleFonts.shareTechMonoTextTheme(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter web chat app',
      theme: defaultThemeForWebApp,
      debugShowCheckedModeBanner: false,
      initialRoute: initialPage,
      onGenerateRoute: RoutesPage.createRoutes,
    );
  }
}