/// Utility functions for processing course names
class CourseNameUtils {
  /// Extracts Hebrew course name from full course name
  /// Actual format: "[course number] - [hebrew name][course number] - [english name]"
  /// Output: "[course number] - [hebrew name]"
  static String extractHebrewCourseName(String fullName) {
    // Extract the course number (digits at the start)
    final courseNumberMatch = RegExp(r'^(\d+)').firstMatch(fullName);
    if (courseNumberMatch == null) {
      return fullName;
    }
    
    final courseNumber = courseNumberMatch.group(1)!;
    
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
}
