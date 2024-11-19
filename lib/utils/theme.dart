import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define primary and additional colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color darkGreen =
      Color(0xFF388E3C); // Dark green for links and text
  static const Color cardGreen = Color(0xFFE8F5E9);
  static const Color lightCardGreen = Color(0xFFF1F8E9);
  static const Color lightBackgroundGreen = Color(0xFFE8F5E9);
  static const Color inputFillColor = Color(0xFFF5F5F5);
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);

  // Define light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: MaterialColor(
      primaryColor.value,
      {
        50: Color(0xFFE8F5E9),
        100: Color(0xFFC8E6C9),
        200: Color(0xFFA5D6A7),
        300: Color(0xFF81C784),
        400: Color(0xFF66BB6A),
        500: Color(0xFF4CAF50), // Primary color
        600: Color(0xFF43A047),
        700: Color(0xFF388E3C),
        800: Color(0xFF2E7D32),
        900: Color(0xFF1B5E20),
      },
    ),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    shadowColor: Colors.black12,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.black),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkGreen, // Apply dark green color to links
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFillColor,
      hintStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2.0,
        ),
      ),
    ),
  );
}
