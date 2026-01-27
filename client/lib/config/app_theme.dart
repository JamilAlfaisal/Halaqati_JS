import 'package:flutter/material.dart';

// 1. Define Color Constants (for easy reference)
class AppColors {
  // Primary Color: for most buttons, big texts, and active elements (195980)
  static const Color primaryBlue = Color(0xFF195980);

  // Secondary Color: for some buttons, inactive elements, hints (97D5DD)
  static const Color accentCyan = Color(0xFF97D5DD);

  // Backgrounds and Text on Primary Buttons
  static const Color backgroundWhite = Colors.white;
  static const Color textOnPrimary = Colors.white;

  // for filter buttons
  static const Color greyColor = Color(0xFFDBDBE5);
}

// 2. Define the Application Theme
class AppTheme {
  static ThemeData lightTheme() {
    // 2.1 Base Theme and Color Scheme
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentCyan,
      background: AppColors.backgroundWhite,
      surface: AppColors.backgroundWhite,
      // Text color on primary buttons is defined here for the general scheme
      onPrimary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.greyColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      fontFamily: 'Inter', // A modern, readable default font (or pick your own)

      iconTheme: const IconThemeData(
        color: AppColors.primaryBlue, // Set your specific color here
        size: 30.0,              // Optionally set a global size
        opacity: 0.9,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundWhite, // Background of the bar itself
        selectedItemColor: AppColors.primaryBlue, // Color of the active icon/label
        unselectedItemColor: AppColors.accentCyan, // Color of inactive icons/labels
        elevation: 8, // Shadow under the bar
        type: BottomNavigationBarType.fixed, // Use 'shifting' for a different style
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),

      // Global theme for all InputDecorations (used by TextFormField)
      inputDecorationTheme: const InputDecorationTheme(
        // Default label text style
        labelStyle: TextStyle(color: AppColors.accentCyan ,fontSize: 18),

        // Default border style
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.greyColor, width: 2.0), // You might be defining a different color here
        ),

        // Style when the field is focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 3.0), // A dramatic change for demonstration
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 3.0), // A dramatic change for demonstration
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 3.0), // A dramatic change for demonstration
        ),
        // Optional: Default hint style
        hintStyle: TextStyle(color: AppColors.accentCyan, fontSize: 14),
        suffixIconColor: AppColors.primaryBlue,
        prefixIconColor: AppColors.primaryBlue,
        // Optional: Padding
        contentPadding: EdgeInsets.all(18.0),
      ),


      // 2.2 Text Theme Configuration
      textTheme: _buildTextTheme(colorScheme),

      // 2.3 Elevated Button Theme (Primary Button Style)
      // Uses primaryBlue for the button, and white for the text inside.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textOnPrimary, // Text color: White
          backgroundColor: AppColors.primaryBlue, // Button color: Primary Blue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2.4 Text Button Theme (Hint/Small Text Style)
      // Uses accentCyan for text buttons and small text/hints.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan, // Text color: Accent Cyan
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 2.5 AppBar Theme (using primary blue for active and background)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.primaryBlue, // Title/icon color
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 2.6 Floating Action Button Theme (example)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
      ),
    );
  }

  // Helper method to configure the Text Theme
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Headline/Display for big texts (use primaryBlue)
      displayLarge: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),

      // Body text (can use primary, but often uses a slightly darker neutral color for readability,
      // here we stick to primary for consistency with your request for "big texts")
      titleLarge: TextStyle(color: colorScheme.onPrimary, fontSize: 17, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: colorScheme.primary, fontSize: 17, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: colorScheme.primary, fontSize: 14),

      // Hint and Caption text (use accentCyan)
      labelSmall: TextStyle(color: colorScheme.secondary, fontSize: 12),
      titleSmall: TextStyle(color: colorScheme.secondary, fontSize: 14),
    );
  }
}