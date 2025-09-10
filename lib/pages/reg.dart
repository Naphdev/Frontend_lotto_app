// ignore_for_file: use_build_context_synchronously, unused_field, sort_child_properties_last

import 'dart:developer' as dev;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'package:lotto_app/pages/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String url = '';
  TextEditingController nameNoCtl = TextEditingController();
  TextEditingController emailNoCtl = TextEditingController();
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();
  TextEditingController confpassNoCtl = TextEditingController();
  bool _isNotValidata = false;

  void registerUser() async {
    if (nameNoCtl.text.isNotEmpty &&
        emailNoCtl.text.isNotEmpty &&
        phoneNoCtl.text.isNotEmpty &&
        passNoCtl.text.isNotEmpty &&
        confpassNoCtl.text.isNotEmpty) {
      var reqBody = {
        "name": nameNoCtl.text,
        "email": emailNoCtl.text,
        "phone": phoneNoCtl.text,
        "password": passNoCtl.text,
        "confpass": confpassNoCtl.text,
      };

      try {
        var response = await http.post(Uri.parse(registerion),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        var jsonResponse = jsonDecode(response.body);

        dev.log("Response status: ${jsonResponse['status']}");

        if (jsonResponse['status'] == true) {
          _showSuccessSnackBar('สมัครสมาชิกสำเร็จ!');
          Future.delayed(const Duration(seconds: 2), () {
            navigateToLogin();
          });
        } else {
          _showErrorSnackBar('การสมัครสมาชิกล้มเหลว โปรดลองใหม่อีกครั้ง');
        }
      } catch (e) {
        dev.log("Error during registration: $e");
        _showErrorSnackBar('เกิดข้อผิดพลาด โปรดลองใหม่อีกครั้งในภายหลัง');
      }
    } else {
      setState(() {
        _isNotValidata = true;
      });
      _showErrorSnackBar('กรุณากรอกข้อมูลให้ครบถ้วน');
    }
  }

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7E57C2),
              Color(0xFF9575CD),
              Color(0xFFB39DDB),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const SizedBox(height: 40),

                  // Logo and Welcome Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'สร้างบัญชีใหม่เพื่อเริ่มต้น',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Registration Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อมูลส่วนตัว',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'กรุณากรอกข้อมูลให้ครบถ้วน',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Full Name Field
                          _buildTextField(
                            'ชื่อ-นามสกุล',
                            nameNoCtl,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          _buildTextField(
                            'อีเมล',
                            emailNoCtl,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Phone Field
                          _buildTextField(
                            'เบอร์โทรศัพท์',
                            phoneNoCtl,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          _buildTextField(
                            'รหัสผ่าน',
                            passNoCtl,
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          _buildTextField(
                            'ยืนยันรหัสผ่าน',
                            confpassNoCtl,
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),

                          // Register Button
                          _buildButton('สมัครสมาชิก', registerUser,
                              isPrimary: true),
                          const SizedBox(height: 16),

                          // Sign In Button
                          _buildButton('เข้าสู่ระบบ', navigateToLogin,
                              isPrimary: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF212121),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: const Color(0xFF7E57C2),
                  size: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool isPrimary = true}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white,
                width: 2,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF7E57C2).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginPage()),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF81C784),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ปิด',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ปิด',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
