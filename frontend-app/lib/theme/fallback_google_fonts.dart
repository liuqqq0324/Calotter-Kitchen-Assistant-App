import 'package:flutter/material.dart';

/// Fallback for GoogleFonts when runtime fetching is disabled or package is removed.
/// It maps to local font families declared in pubspec.yaml (e.g., Caveat).
class GoogleFonts {
  static TextStyle caveat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Caveat',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle kalam({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Caveat', // fallback to Caveat since Kalam not packaged
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Caveat', // fallback to Caveat since Poppins not packaged
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle dancingScript({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Caveat', // fallback to Caveat since DancingScript not packaged
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
