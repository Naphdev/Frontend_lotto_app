import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:lotto_app/utils/snackbar_helper.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error,
      {String? customMessage}) {
    String errorMessage = _getErrorMessage(error);

    // Log error for debugging
    dev.log('Error occurred: $error',
        error: error, stackTrace: StackTrace.current);

    // Show user-friendly error message
    if (customMessage != null) {
      SnackbarHelper.showErrorSnackBar(context, customMessage);
    } else {
      SnackbarHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    // Handle HTTP errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
    }

    if (error.toString().contains('FormatException')) {
      return 'ข้อมูลที่ได้รับไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง';
    }

    // Handle specific API errors
    if (error.toString().contains('401')) {
      return 'การเข้าสู่ระบบหมดอายุ กรุณาเข้าสู่ระบบใหม่';
    }

    if (error.toString().contains('403')) {
      return 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้';
    }

    if (error.toString().contains('404')) {
      return 'ไม่พบข้อมูลที่ต้องการ';
    }

    if (error.toString().contains('500')) {
      return 'เกิดข้อผิดพลาดในระบบ กรุณาลองใหม่อีกครั้ง';
    }

    // Default error message
    return 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง';
  }

  static void handleApiError(BuildContext context, int statusCode,
      {String? customMessage}) {
    String errorMessage = _getApiErrorMessage(statusCode);

    dev.log('API Error: $statusCode - $errorMessage');

    if (customMessage != null) {
      SnackbarHelper.showErrorSnackBar(context, customMessage);
    } else {
      SnackbarHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  static String _getApiErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'ข้อมูลที่ส่งไม่ถูกต้อง';
      case 401:
        return 'การเข้าสู่ระบบหมดอายุ กรุณาเข้าสู่ระบบใหม่';
      case 403:
        return 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้';
      case 404:
        return 'ไม่พบข้อมูลที่ต้องการ';
      case 409:
        return 'ข้อมูลซ้ำกับที่มีอยู่แล้ว';
      case 422:
        return 'ข้อมูลไม่ถูกต้องตามเงื่อนไข';
      case 429:
        return 'มีการเรียกใช้ API มากเกินไป กรุณารอสักครู่';
      case 500:
        return 'เกิดข้อผิดพลาดในระบบ กรุณาลองใหม่อีกครั้ง';
      case 502:
        return 'เซิร์ฟเวอร์ไม่พร้อมใช้งาน';
      case 503:
        return 'ระบบกำลังบำรุงรักษา กรุณาลองใหม่อีกครั้ง';
      default:
        return 'เกิดข้อผิดพลาด (รหัส: $statusCode)';
    }
  }

  static void showSuccessMessage(BuildContext context, String message) {
    SnackbarHelper.showSuccessSnackBar(context, message);
  }

  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
