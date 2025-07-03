import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp/main.dart'; // Make sure this matches your app package name

void main() {
  testWidgets('WeatherApp basic UI loads', (WidgetTester tester) async {
  
    await tester.pumpWidget(const WeatherApp());

  
    expect(find.text('Weather App'), findsOneWidget);

 
    expect(find.byType(TextField), findsOneWidget);


    expect(find.byIcon(Icons.search), findsOneWidget);

    
    await tester.tap(find.byIcon(Icons.brightness_6));
    await tester.pump();


    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.pump();
  });
}
