import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/article/article_widget.dart';
import 'package:timeline/timeline/timeline_entry.dart';

void main() {
  group('ArticleWidget', () {
    testWidgets('should display article title', (WidgetTester tester) async {
      final entry = TimelineEntry()
        ..label = 'Test Article'
        ..start = 1000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleWidget(article: entry),
        ),
      );

      expect(find.text('Test Article'), findsOneWidget);
      
      // Clean up any pending animations
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('should show back button', (WidgetTester tester) async {
      final entry = TimelineEntry()
        ..label = 'Test Article'
        ..start = 1000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleWidget(article: entry),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('should show loading indicator when no markdown', (WidgetTester tester) async {
      final entry = TimelineEntry()
        ..label = 'Test Article'
        ..start = 1000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleWidget(article: entry),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('should have scroll view for content', (WidgetTester tester) async {
      final entry = TimelineEntry()
        ..label = 'Test Article'
        ..start = 1000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ArticleWidget(article: entry),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}