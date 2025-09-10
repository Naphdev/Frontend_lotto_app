import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Lotto App';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF7E57C2);
  static const Color secondaryColor = Color(0xFFD1C4E9);
  static const Color backgroundColor = Color(0xFFE0E0E0);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color infoColor = Color(0xFF64B5F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 30.0;

  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 32.0;

  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;

  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Lotto specific
  static const int lottoNumberLength = 6;
  static const double lottoTicketPrice = 100.0;

  // Error Messages
  static const String networkErrorMessage = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
  static const String timeoutErrorMessage = 'การเชื่อมต่อหมดเวลา';
  static const String unknownErrorMessage = 'เกิดข้อผิดพลาดที่ไม่คาดคิด';
  static const String validationErrorMessage = 'ข้อมูลไม่ถูกต้อง';

  // Success Messages
  static const String loginSuccessMessage = 'เข้าสู่ระบบสำเร็จ';
  static const String logoutSuccessMessage = 'ออกจากระบบสำเร็จ';
  static const String purchaseSuccessMessage = 'ซื้อสลากสำเร็จ';
  static const String registrationSuccessMessage = 'สมัครสมาชิกสำเร็จ';
}
