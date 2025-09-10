import 'dart:developer' as dev;
import 'package:lotto_app/config/configg.dart' as config;
import 'package:lotto_app/services/api_service.dart';

class AuthService {
  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        config.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response['status'] == true) {
        return {
          'success': true,
          'token': response['token'],
          'userType': response['userType'],
          'message': response['message'] ?? 'เข้าสู่ระบบสำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'การเข้าสู่ระบบล้มเหลว',
        };
      }
    } catch (e) {
      dev.log('Login error: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
      };
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.post(
        config.registerion,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confpass': confirmPassword,
        },
      );

      if (response['status'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'สมัครสมาชิกสำเร็จ',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'การสมัครสมาชิกล้มเหลว',
        };
      }
    } catch (e) {
      dev.log('Registration error: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการสมัครสมาชิก',
      };
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone.replaceAll('-', ''));
  }

  // Validate name
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  // Validate confirm password
  static bool isPasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // Get validation error message
  static String? getValidationError({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? phone,
  }) {
    if (email != null && !isValidEmail(email)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }

    if (password != null && !isValidPassword(password)) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    if (name != null && !isValidName(name)) {
      return 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';
    }

    if (phone != null && !isValidPhone(phone)) {
      return 'หมายเลขโทรศัพท์ไม่ถูกต้อง';
    }

    if (password != null &&
        confirmPassword != null &&
        !isPasswordMatch(password, confirmPassword)) {
      return 'รหัสผ่านไม่ตรงกัน';
    }

    return null;
  }
}
