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

  // Summary
  static const String noDeadlinesThisWeek = 'אין מטלות השבוע';
  static const String oneDeadlineThisWeek = 'יש לך מטלה אחת להגשה השבוע';
  static const String multipleDeadlinesThisWeek = 'יש לך {count} מטלות להגשה השבוע';

  // Empty state
  static const String noTasks = 'אין מטלות להגשה';
  static const String showHiddenTasks = 'הצג מטלות שהוסתרו';
  static const String hideHiddenTasks = 'הסתר מטלות שהוסתרו';
  static const String markAsDone = 'סמן כהושלם';
  static const String hideTask = 'הסתר';
  static const String restoreTask = 'שחזר';
  static const String taskHidden = 'המטלה הוסתרה';
  static const String taskRestored = 'המטלה שוחזרה';
  static const String taskMarkingErrorMissingId = 'לא ניתן לסמן מטלה זו (חסר מזהה רכיב)';
  static const String taskMarkingInProgress = 'מעדכן מול Moodle...';
  static const String taskMarkedAsDone = 'סומן כבוצע!';
  static const String taskMarkingError = 'שגיאה בסימון המטלה, ייתכן ולא ניתן לסמן מטלה זו כבוצעה';

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
  static const String settingsTitle = 'הגדרות';
  static const String settingsDescription = 'הגדר את פרטי ההתחברות שלך ל-Moodle כדי לגשת למטלות ולמועדי ההגשה';
  static const String appearanceSection = 'מראה';
  static const String connectionSection = 'פרטי התחברות';
  static const String themeModeLight = 'בהיר';
  static const String themeModeDark = 'כהה';
  static const String themeModeSystem = 'אוטומטי';
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
  
  // Validation messages
  static const String validatingCredentials = 'מאמת פרטי התחברות...';
  static const String validationConnectionError = 'לא ניתן להתחבר ל-Moodle. נא לבדוק את כתובת ה-URL והחיבור לאינטרנט';
  static const String validationTimeout = 'תם הזמן לחיבור. נא לבדוק את כתובת ה-URL';
  static const String validationInvalidToken = 'הטוקן שגוי או פג תוקף.';
  
  static const String tokenInstructionsTitle = 'איך להשיג את טוקן ה-Moodle';
  static const String tokenInstructions = '1. התחבר לאתר ה-Moodle שלך\n'
      '2. עבור להעדפות > חשבון משתמש > מפתחות אבטחה\n'
      '3. אפס את הטוקן "Moodle mobile web service"\n'
      '4. העתק את הטוקן החדש שיוצג והדבק אותו למעלה';

  // Credentials Required
  static const String credentialsRequiredTitle = 'נדרשים פרטי התחברות';
  static const String credentialsRequiredMessage = 'נא להגדיר את פרטי ההתחברות ל-Moodle כדי לגשת למטלות ולמשימות שלך';
  static const String goToSettingsButton = 'עבור להגדרות';

  // First launch
  static const String firstLaunchMessage = 'נא להגדיר את פרטי ההתחברות ל-Moodle כדי להתחיל';

  // Notifications
  static const String notificationNewTaskTitle = '\u200Fמטלה חדשה: {course}';
  static const String notificationDeadlineTitle = '\u200Fמועד הגשה מתקרב';
  static const String notificationDeadlineBody = '\u200F{task} להגשה בקרוב!';
  static const String notificationChannelNewTasks = 'מטלות חדשות';
  static const String notificationChannelNewTasksDesc = 'התראות על מטלות חדשות שנוספו';
  static const String notificationChannelDeadlines = 'מועדי הגשה';
  static const String notificationChannelDeadlinesDesc = 'התראות על מועדי הגשה מתקרבים';

  // Notification Settings
  static const String notificationsSection = 'התראות';
  static const String notifyNewTasks = 'מטלות חדשות';
  static const String notifyNewTasksDesc = 'קבל התראה כשמטלה חדשה מתגלה';
  static const String notifyDeadlines = 'תזכורת דדליין';
  static const String notifyDeadlinesDesc = 'קבל התראה לפני מועד ההגשה';
  static const String alertTime15Minutes = '15 דקות לפני';
  static const String alertTime1Hour = 'שעה לפני';
  static const String alertTime1Day = 'יום לפני';
  static const String alertTime2Days = 'יומיים לפני';
  static const String permissionsRequired = 'נדרשת הרשאה כדי לאפשר התראות';

  // Onboarding
  static const String onboardingWelcomeTitle = 'היי, אני מודי!';
  static const String onboardingWelcomeBody = 'באתי לעשות לך סדר בלוח הזמנים כדי שתוכל/י להתרכז בלימודים (ובכיף)';
  static const String onboardingNext = 'נעים להכיר!';
  static const String onboardingContinue = 'המשך';
  static const String onboardingFinish = 'סיום';
  static const String onboardingSkip = 'דלג';
  static const String onboardingConfigBody = 'כדי שאוכל להציג את הלו"ז הנכון, אני צריך כמה פרטים קטנים';
  static const String onboardingTokenHelpTitle = 'איך משיגים טוקן?';
  
  static const String onboardingWidgetTitle = 'הלו"ז תמיד מול העיניים';
  static const String onboardingWidgetBody = 'רק דבר קטן אחרון, יש לי ווידג\'ט מעולה למסך הבית. ככה לא צריך לפתוח את האפליקציה כדי לראות מה השיעור הבא!';
  static const String onboardingWidgetButton = 'נשמע מעולה, בוא נתחיל!';

  static const String onboardingPermissionsTitle = 'לא מפספסים כלום';
  static const String onboardingPermissionsBody = 'רוצה שאזכיר לך לפני שזמן ההגשה מגיע, או כשקיבלת מטלה חדשה? מבטיח לא לחפור סתם';
  static const String onboardingPermissionsButton = 'בטח, תזכיר לי';
  static const String onboardingPermissionsSkip = 'לא עכשיו';
}
