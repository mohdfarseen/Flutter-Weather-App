import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp/main.dart'; // Make sure this matches your app package name

void main() {
  testWidgets('WeatherApp basic UI loads', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const WeatherApp());

    // Verify AppBar title
    expect(find.text('Weather App'), findsOneWidget);

    // Verify presence of text input for city search
    expect(find.byType(TextField), findsOneWidget);

    // Verify search icon exists
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Tap the brightness toggle button (dark mode)
    await tester.tap(find.byIcon(Icons.brightness_6));
    await tester.pump();

    // Type a city name in the search field
    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.pump();
  });
}
