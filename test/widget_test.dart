import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/main.dart';

void main() {
  testWidgets('App shows splash branding', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('LifeOS'), findsOneWidget);
    expect(find.text('Manage Your Entire Life in One Place'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('App renders on a tablet viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('LifeOS'), findsOneWidget);

    // Flush Splash's delayed navigation timer to avoid pending timers on teardown.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
