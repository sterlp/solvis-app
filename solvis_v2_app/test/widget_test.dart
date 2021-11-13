// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solvis_v2_app/app_config.dart';
import 'package:solvis_v2_app/homescreen/solvis_home_page.dart';

import 'package:solvis_v2_app/main.dart';
import 'package:solvis_v2_app/settings/server_settings_page.dart';
import 'package:solvis_v2_app/solvis/solvis_client.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  var mock = MockSharedPreferences();

  setUp(() {
    mock = MockSharedPreferences();
  });

  testWidgets('Opens settings screen of no URL is configured', (WidgetTester tester) async {
    when(mock.getString('solvis_user')).thenReturn(null);
    when(mock.getString('solvis_password')).thenReturn(null);
    when(mock.getString('solvis_url')).thenReturn(null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(container: buildContext(Future.value(mock))));
    await tester.pumpAndSettle();

    expect(find.byType(ServerSettingsPage), findsOneWidget);
    expect(find.text('Solvis V2 Einstellungen'), findsOneWidget);
  });

  testWidgets('Shows Home Screen with URL', (WidgetTester tester) async {
    initPrefsMock(mock);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(container: buildContext(Future.value(mock))));
    // loading screen
    expect(find.text('Solvis V2 Control'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SolvisHomePage), findsNothing);

    // main screen
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SolvisHomePage), findsOneWidget);
  });

  testWidgets("Shows error that solvis can't be reached", (WidgetTester tester) async {
    initPrefsMock(mock);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(container: buildContext(Future.value(mock))));
    await tester.pumpAndSettle();

    expect(find.text('Solvis Heizung nicht erreicht.'), findsOneWidget);
  });

  testWidgets('Show SolvisHomePage', (WidgetTester tester) async {
    initPrefsMock(mock);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(container: buildContext(Future.value(mock))));
    await tester.pump();

    expect(find.byType(SolvisHomePage), findsOneWidget);
  });

  testWidgets('Verify floating button visibility based on URL', (WidgetTester tester) async {
    initPrefsMock(mock, setNull: true);

    final c = buildContext(Future.value(mock));

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(container: c));
    await tester.pump();

    expect(find.byType(SolvisHomePage), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    final ctx = await c;
    ctx.get<SolvisClient>().server = 'http://localhost';

    await tester.pump();
    expect(find.text ('zurück'), findsNothing);
  });
}

void initPrefsMock(MockSharedPreferences mock, {bool setNull = false}) {
  when(mock.getString('solvis_user')).thenReturn(setNull ? null : 'user');
  when(mock.getString('solvis_password')).thenReturn(setNull ? null : 'pass');
  when(mock.getString('solvis_url')).thenReturn(setNull ? null : 'http://localhost');
}
