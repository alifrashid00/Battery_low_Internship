// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:idcard/main.dart';

void main() {
  testWidgets('ID card renders expected fields', (WidgetTester tester) async {
    await tester.pumpWidget(const IdCardApp());

    expect(find.text('ISLAMIC UNIVERSITY OF TECHNOLOGY'), findsOneWidget);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('210041254'), findsOneWidget);
    expect(find.text('Student Name'), findsOneWidget);
    expect(find.text('ASIF OR RASHID ALIF'), findsOneWidget);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('B.Sc. in CSE'), findsOneWidget);
    expect(find.text('Department'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget);
    expect(find.text('Nationality'), findsOneWidget);
    expect(find.text('Bangladesh'), findsOneWidget);
    expect(find.text('A subsidiary organ of OIC'), findsOneWidget);
  });
}
