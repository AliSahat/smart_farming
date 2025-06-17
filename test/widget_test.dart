// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farming/main.dart';

void main() {
  testWidgets('Smart Farming App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartFarmingApp());

    // Verify that the Smart Farming title is present
    expect(find.text('Smart Farming Control'), findsOneWidget);

    // Verify that the subtitle is present
    expect(
      find.text('Sistem Monitoring Ketinggian Air Otomatis'),
      findsOneWidget,
    );

    // Verify that the connection status indicator is present
    expect(find.text('Terhubung'), findsOneWidget);

    // Verify that some key widgets are present
    expect(find.text('Pilih Kolam/Wadah'), findsOneWidget);
    expect(find.text('Status Kontrol'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);

    // Test settings button tap
    final settingsButton = find.byIcon(Icons.settings);
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pump();

    // After tapping settings, the pool settings should appear
    expect(find.text('Pengaturan Kolam/Wadah'), findsOneWidget);
  });

  testWidgets('Pool selection test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFarmingApp());

    // Find and tap on a different pool
    final kolamIkanButton = find.text('Kolam Ikan');
    expect(kolamIkanButton, findsOneWidget);

    await tester.tap(kolamIkanButton);
    await tester.pump();

    // Verify the pool selection worked
    expect(find.text('Kolam Ikan'), findsOneWidget);
  });

  testWidgets('Manual controls test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFarmingApp());

    // Find the manual control switch
    final manualSwitch = find.byType(Switch);
    expect(manualSwitch, findsOneWidget);

    // Tap the switch to enable manual mode
    await tester.tap(manualSwitch);
    await tester.pump();

    // After enabling manual mode, control buttons should appear
    expect(find.text('Buka Kran Air'), findsOneWidget);
    expect(find.text('Tutup Kran Air'), findsOneWidget);
    expect(find.text('Buka Pembuangan'), findsOneWidget);
    expect(find.text('Reset Sistem'), findsOneWidget);
  });
}
