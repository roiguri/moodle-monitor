/// Utility functions for processing course names
/// Handles dual-language course names in format: "[course number] - [hebrew name][course number] - [english name]"
class CourseNameUtils {
  /// Extracts the course number from course name
  /// Example: "0609101801 - קשב ולמידה0609101801 - Attention and Learning" → "0609101801"
  static String extractCourseNumber(String fullName) {
    final courseNumberMatch = RegExp(r'^(\d+)').firstMatch(fullName);
    if (courseNumberMatch == null) {
      return '';
    }
    return courseNumberMatch.group(1)!;
  }

  /// Extracts Hebrew name with course number
  /// Example: "0609101801 - קשב ולמידה0609101801 - Attention and Learning" → "0609101801 - קשב ולמידה"
  static String extractHebrewCourseName(String fullName) {
    final courseNumber = extractCourseNumber(fullName);
    if (courseNumber.isEmpty) {
      return fullName;
    }
    
    // Find the second occurrence of the course number
    final firstOccurrence = fullName.indexOf(courseNumber);
    final secondOccurrence = fullName.indexOf(courseNumber, firstOccurrence + courseNumber.length);
    
    if (secondOccurrence == -1) {
      // No second occurrence, return original
      return fullName;
    }
    
    // Extract from start to just before the second occurrence
    return fullName.substring(0, secondOccurrence).trim();
  }

  /// Extracts only the Hebrew name without course number
  /// Example: "0609101801 - קשב ולמידה0609101801 - Attention and Learning" → "קשב ולמידה"
  static String extractHebrewName(String fullName) {
    final hebrewWithNumber = extractHebrewCourseName(fullName);
    final courseNumber = extractCourseNumber(fullName);
    
    if (courseNumber.isEmpty) {
      return hebrewWithNumber;
    }
    
    // Remove course number and dash prefix
    return hebrewWithNumber
        .replaceFirst('$courseNumber - ', '')
        .trim();
  }

  /// Extracts English name with course number
  /// Example: "0609101801 - קשב ולמידה0609101801 - Attention and Learning" → "0609101801 - Attention and Learning"
  static String extractEnglishCourseName(String fullName) {
    final courseNumber = extractCourseNumber(fullName);
    if (courseNumber.isEmpty) {
      return fullName;
    }
    
    // Find the second occurrence of the course number
    final firstOccurrence = fullName.indexOf(courseNumber);
    final secondOccurrence = fullName.indexOf(courseNumber, firstOccurrence + courseNumber.length);
    
    if (secondOccurrence == -1) {
      // No second occurrence, return original
      return fullName;
    }
    
    // Extract from second occurrence to end
    return fullName.substring(secondOccurrence).trim();
  }

  /// Extracts only the English name without course number
  /// Example: "0609101801 - קשב ולמידה0609101801 - Attention and Learning" → "Attention and Learning"
  static String extractEnglishName(String fullName) {
    final englishWithNumber = extractEnglishCourseName(fullName);
    final courseNumber = extractCourseNumber(fullName);
    
    if (courseNumber.isEmpty) {
      return englishWithNumber;
    }
    
    // Remove course number and dash prefix
    return englishWithNumber
        .replaceFirst('$courseNumber - ', '')
        .trim();
  }

  /// Legacy method used by TasksView - cleans course name for display
  /// Removes course codes and normalizes formatting
  static String cleanCourseName(String name) {
    // Extract only the Hebrew name
    return extractHebrewName(name);
  }
}
