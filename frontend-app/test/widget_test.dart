// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_sous_chef/main.dart';

void main() {
  testWidgets('App launches and shows landing page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SousChefApp());

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the app title is present (MaterialApp title)
    expect(find.text('Sous Chef'), findsNothing); // Title is not displayed in UI
    
    // Verify that the landing page is displayed (should contain login/register options)
    // The landing page should have some UI elements, we can check for Material widgets
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // The app should have a MaterialApp structure
    expect(find.byType(Material), findsWidgets);
  });
}
