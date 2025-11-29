class AppStrings {
  // Greetings (based on time of day)
  static const String goodMorning = 'בוקר טוב';
  static const String goodAfternoon = 'צהריים טובים';
  static const String goodEvening = 'ערב טוב';
  static const String goodNight = 'לילה טוב';

  // Date labels
  static const String today = 'היום';
  static const String tomorrow = 'מחר';
  static const String next7Days = '7 הימים הבאים';
  static const String next30Days = '30 הימים הבאים';
  static const String later = 'מאוחר יותר';

  // Summary (with proper Hebrew grammar)
  static const String noDeadlinesThisWeek = 'אין מטלות השבוע';
  static const String oneDeadlineThisWeek = 'יש לך מטלה אחת להגשה השבוע';
  static const String multipleDeadlinesThisWeek = 'יש לך {count} מטלות להגשה השבוע';

  // Empty state
  static const String noTasks = 'אין מטלות להגשה';

  // Error messages
  static const String loadError = 'שגיאה בטעינת המידע';
  static const String refreshError = 'שגיאה ברענון';
  static const String retryButton = 'נסה שוב';
  static const String credentialsExpired = 'פרטי ההתחברות לא תקינים או פגו תוקף';
  static const String credentialsMissing = 'פרטי ההתחברות נמחקו. המטלות המוצגות הן מהטעינה האחרונה';
  static const String updateCredentialsButton = 'עדכן פרטי התחברות';
  static const String invalidCredentials = 'פרטי ההתחברות שגויים. נא לבדוק את הטוקן והכתובת';

  // Navigation
  static const String navTasks = 'משימות';
  static const String navCourses = 'קורסים';
  static const String navSettings = 'הגדרות';

  // Courses
  static const String coursesTitle = 'כל הקורסים';
  static const String myCoursesTitle = 'הקורסים שלי';
  static const String hiddenCoursesSection = 'קורסים מוסתרים';
  static const String noCourses = 'אין קורסים';
  static const String courseVisible = 'קורס גלוי';
  static const String courseHidden = 'קורס מוסתר';
  static const String showCourse = 'הצג קורס';
  static const String hideCourse = 'הסתר קורס';
  static const String openInMoodle = 'פתח ב-Moodle';
  static const String fetchCoursesError = 'שגיאה בטעינת קורסים';

  // Settings
  static const String settingsTitle = 'הגדרות Moodle';
  static const String settingsDescription = 'הגדר את פרטי ההתחברות שלך ל-Moodle כדי לגשת למטלות ולמועדי ההגשה';
  static const String moodleUrlLabel = 'כתובת Moodle';
  static const String moodleUrlHint = 'https://moodle.yourschool.edu';
  static const String moodleTokenLabel = 'טוקן Moodle';
  static const String moodleTokenHint = 'טוקן API שלך';
  static const String saveButton = 'שמור פרטים';
  static const String clearButton = 'נקה פרטים';
  static const String clearConfirmTitle = 'נקה פרטים';
  static const String clearConfirmMessage = 'האם אתה בטוח שברצונך למחוק את פרטי ההתחברות ל-Moodle?';
  static const String cancelButton = 'ביטול';
  static const String clearConfirmButton = 'נקה';
  static const String credentialsSaved = 'הפרטים נשמרו בהצלחה!';
  static const String credentialsCleared = 'הפרטים נוקו';
  static const String saveError = 'שגיאה בשמירת הפרטים';
  static const String urlRequired = 'נא להזין את כתובת Moodle';
  static const String urlInvalid = 'הכתובת חייבת להתחיל ב-http:// או https://';
  static const String tokenRequired = 'נא להזין את טוקן Moodle';
  static const String tokenInstructionsTitle = 'איך להשיג את טוקן ה-Moodle';
  static const String tokenInstructions = '1. התחבר לאתר ה-Moodle שלך\n'
      '2. עבור להעדפות ← חשבון משתמש ← מפתחות אבטחה\n'
      '3. אפס את הטוקן "Moodle mobile web service"\n'
      '4. העתק את הטוקן החדש שיוצג והדבק אותו למעלה';

  // Credentials Required
  static const String credentialsRequiredTitle = 'נדרשים פרטי התחברות';
  static const String credentialsRequiredMessage = 'נא להגדיר את פרטי ההתחברות ל-Moodle כדי לגשת למטלות ולמשימות שלך';
  static const String goToSettingsButton = 'עבור להגדרות';

  // First launch
  static const String firstLaunchMessage = 'נא להגדיר את פרטי ההתחברות ל-Moodle כדי להתחיל';
}
