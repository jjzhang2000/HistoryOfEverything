import 'package:flutter_test/flutter_test.dart';
import 'package:timeline/timeline/timeline_entry.dart';

void main() {
  group('TimelineEntry', () {
    test('should create TimelineEntry object', () {
      final entry = TimelineEntry();
      
      expect(entry, isNotNull);
      expect(entry, isA<TimelineEntry>());
    });

    test('should set and get label property', () {
      final entry = TimelineEntry();
      const testLabel = 'Big Bang';
      
      entry.label = testLabel;
      
      expect(entry.label, equals(testLabel));
    });

    test('should handle label with newlines', () {
      final entry = TimelineEntry();
      const testLabel = 'Line 1\nLine 2\nLine 3';
      
      entry.label = testLabel;
      
      expect(entry.label, equals(testLabel));
      expect(entry.lineCount, equals(3));
    });

    test('should handle empty label', () {
      final entry = TimelineEntry();
      
      entry.label = '';
      
      expect(entry.label, equals(''));
      expect(entry.lineCount, equals(1));
    });

    test('should handle null label', () {
      final entry = TimelineEntry();
      
      expect(entry.label, equals(''));
    });

    test('should set and get start property', () {
      final entry = TimelineEntry();
      const testStart = -13800000000.0;
      
      entry.start = testStart;
      
      expect(entry.start, equals(testStart));
    });

    test('should set and get end property', () {
      final entry = TimelineEntry();
      const testEnd = 2024.0;
      
      entry.end = testEnd;
      
      expect(entry.end, equals(testEnd));
    });

    test('should set TimelineEntryType', () {
      final entry = TimelineEntry();
      
      entry.type = TimelineEntryType.Incident;
      expect(entry.type, equals(TimelineEntryType.Incident));
      
      entry.type = TimelineEntryType.Era;
      expect(entry.type, equals(TimelineEntryType.Era));
    });

    group('formatYears', () {
      test('should format years less than 10000 correctly', () {
        expect(TimelineEntry.formatYears(5000), equals('5000 Years'));
        expect(TimelineEntry.formatYears(9999), equals('9999 Years'));
      });

      test('should format years in thousands correctly', () {
        expect(TimelineEntry.formatYears(15000), equals('15 Thousand Years'));
        expect(TimelineEntry.formatYears(100000), equals('100 Thousand Years'));
        expect(TimelineEntry.formatYears(999999), equals('1000 Thousand Years'));
      });

      test('should format years in millions correctly', () {
        expect(TimelineEntry.formatYears(1000000), equals('1 Million Years'));
        expect(TimelineEntry.formatYears(1500000), equals('1.5 Million Years'));
        expect(TimelineEntry.formatYears(100000000), equals('100 Million Years'));
      });

      test('should format years in billions correctly', () {
        expect(TimelineEntry.formatYears(1000000000), equals('1 Billion Years'));
        expect(TimelineEntry.formatYears(13800000000), equals('13.8 Billion Years'));
      });

      test('should handle negative years correctly', () {
        expect(TimelineEntry.formatYears(-13800000000), equals('13.8 Billion Years'));
        expect(TimelineEntry.formatYears(-1000000), equals('1 Million Years'));
      });

      test('should handle null value', () {
        expect(TimelineEntry.formatYears(null), equals('Unknown'));
      });
    });

    group('formatYearsAgo', () {
      test('should return formatted string for positive start', () {
        final entry = TimelineEntry();
        entry.start = 2024;
        
        expect(entry.formatYearsAgo(), equals('2024'));
      });

      test('should return "Ago" format for negative start', () {
        final entry = TimelineEntry();
        entry.start = -13800000000;
        
        expect(entry.formatYearsAgo(), equals('13.8 Billion Years Ago'));
      });

      test('should handle zero start', () {
        final entry = TimelineEntry();
        entry.start = 0;
        
        expect(entry.formatYearsAgo(), equals('0 Years Ago'));
      });

      test('should handle null start', () {
        final entry = TimelineEntry();
        entry.start = null;
        
        expect(entry.formatYearsAgo(), equals('Unknown Ago'));
      });
    });

    test('toString should return formatted string', () {
      final entry = TimelineEntry();
      entry.label = 'Test Event';
      entry.start = 1000.0;
      entry.end = 2000.0;
      
      expect(entry.toString(), equals('TIMELINE ENTRY: Test Event -(1000.0,2000.0)'));
    });

    test('isVisible should return true when opacity > 0', () {
      final entry = TimelineEntry();
      
      entry.opacity = 0.0;
      expect(entry.isVisible, isFalse);
      
      entry.opacity = 0.5;
      expect(entry.isVisible, isTrue);
      
      entry.opacity = 1.0;
      expect(entry.isVisible, isTrue);
    });

    test('should set and get id property', () {
      final entry = TimelineEntry();
      const testId = 'big-bang-001';
      
      entry.id = testId;
      
      expect(entry.id, equals(testId));
    });

    test('should set and get articleFilename property', () {
      final entry = TimelineEntry();
      const filename = 'articles/big_bang.md';
      
      entry.articleFilename = filename;
      
      expect(entry.articleFilename, equals(filename));
    });

    test('should set and get parent/children relationships', () {
      final parent = TimelineEntry();
      parent.label = 'Parent Era';
      
      final child = TimelineEntry();
      child.label = 'Child Event';
      child.parent = parent;
      
      expect(child.parent, equals(parent));
      
      parent.children = [child];
      expect(parent.children, contains(child));
    });

    test('should set and get next/previous links', () {
      final entry1 = TimelineEntry();
      entry1.label = 'Event 1';
      
      final entry2 = TimelineEntry();
      entry2.label = 'Event 2';
      
      entry1.next = entry2;
      entry2.previous = entry1;
      
      expect(entry1.next, equals(entry2));
      expect(entry2.previous, equals(entry1));
    });
  });
}
