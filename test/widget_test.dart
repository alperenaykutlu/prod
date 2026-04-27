// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faurecia/screens/login/rf_gun_secim_screen.dart';
import 'package:faurecia/core/theme/app_theme.dart';

void main() {
  testWidgets('FaureciaApp – RF Gun seçim ekranı yüklenir', (WidgetTester tester) async {
    // Zebra el terminali ekran boyutuna yakın bir viewport belirle
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const RfGunSecimScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // "Faurecia" başlığı gösteriliyor
    expect(find.text('Faurecia'), findsOneWidget);
    // 3 RF Gun kartı var
    expect(find.text('RF Gun 1'), findsOneWidget);
    expect(find.text('RF Gun 2'), findsOneWidget);
    expect(find.text('RF Gun 3'), findsOneWidget);
    // Bölge etiketleri
    expect(find.text('Üretim Bölgesi'), findsOneWidget);
    expect(find.text('Kırılma Bölgesi'), findsOneWidget);
    expect(find.text('Silo Bölgesi'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
