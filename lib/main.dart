import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:lds/View/Login.dart';
import 'package:lds/View/PushNotification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  await FlutterDownloader.initialize(debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDS Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary and Accent Colors
        primaryColor: Colors.blue[900],
        hintColor: Colors.orange,

        // Bright Backgrounds and Card Colors
          scaffoldBackgroundColor: const Color(0xFFFEFCFF),

        // Text Theme with Modern Font
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
          displayMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black.withOpacity(0.7),
            fontFamily: 'Roboto',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.6),
            fontFamily: 'Roboto',
          ),
        ),

        // Form Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[900]!, width: 2),
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),

        // Elevated Button Style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], // button background color
            foregroundColor: Colors.white, // button text color
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          ),
        ),

        // App Bar Styling
        appBarTheme: AppBarTheme(
          elevation: 4,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          titleTextStyle:  const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),

        // Card and Other Widgets' Shadows
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // General Button Styles for Icons and Other Buttons
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.blue[900]),
          ),
        ),

        // Bottom Navigation Bar Styling (Optional)
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blue[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          elevation: 10,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
