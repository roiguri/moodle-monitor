import 'package:flutter_test/flutter_test.dart';
import 'package:moodie/utils/course_name_utils.dart';

void main() {
  group('CourseNameUtils', () {
    test('extractHebrewName correctly strips course numbers and delimiters', () {
      final rawName = '0609101801 - קשב ולמידה0609101801 - Attention and Learning';
      final hebrewName = CourseNameUtils.extractHebrewName(rawName);
      expect(hebrewName, 'קשב ולמידה');
    });

    test('extractHebrewName returns original string if no course number', () {
      final rawName = 'Just a Course Name';
      final hebrewName = CourseNameUtils.extractHebrewName(rawName);
      expect(hebrewName, 'Just a Course Name');
    });

    test('extractHebrewName handles single occurrence of course number', () {
       final rawName = '0609101801 - קשב ולמידה';
       final hebrewName = CourseNameUtils.extractHebrewName(rawName);
       expect(hebrewName, 'קשב ולמידה');
    });
  });
}
