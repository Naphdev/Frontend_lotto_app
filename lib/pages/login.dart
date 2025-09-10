// ignore_for_file: camel_case_types, use_build_context_synchronously, sort_child_properties_last, non_constant_identifier_names, unused_element

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

// import 'package:lotto_app/pages/home.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'package:lotto_app/pages/home.dart';
import 'package:lotto_app/pages/reg.dart';
import 'package:lotto_app/pages/adminpages/admin1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  String url = '';
  String text = "";
  TextEditingController emailNoCtl = TextEditingController();
  TextEditingController passNoCtl = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
        url = value['apiEndpoint'];
      },
    );
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailNoCtl.text.isNotEmpty && passNoCtl.text.isNotEmpty) {
      var reqBody = {
        "email": emailNoCtl.text,
        "password": passNoCtl.text,
      };

      try {
        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));

        var jsonResponse = jsonDecode(response.body);
        dev.log(
            'API Response: ${response.body}'); // เพิ่มการล็อกการตอบกลับทั้งหมด

        if (jsonResponse['status']) {
          var myToken = jsonResponse['token'];
          prefs.setString('token', myToken);

          // ตรวจสอบ userType
          String userType = jsonResponse['userType'];
          dev.log('User Type: $userType'); // เพิ่มการล็อก userType

          if (userType.toLowerCase() == 'admin') {
            // เปลี่ยนเป็นตัวพิมพ์เล็กเพื่อการเปรียบเทียบ
            dev.log('Navigating to AdminPage');
            // นำทางไปยังหน้า AdminPage
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Admin1(token: myToken)));
          } else {
            dev.log('Navigating to HomePage');
            // นำทางไปยังหน้า HomePage สำหรับผู้ใช้ทั่วไป
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage(token: myToken)));
          }
        } else {
          setState(() {
            text = "การเข้าสู่ระบบล้มเหลว โปรดตรวจสอบข้อมูลของคุณ";
          });
          dev.log(
              'การเข้าสู่ระบบล้มเหลว: ${jsonResponse['message'] ?? "ข้อผิดพลาดที่ไม่ทราบสาเหตุ"}');
          _showSnackBar("การเข้าสู่ระบบล้มเหลว โปรดตรวจสอบข้อมูลของคุณ");
        }
      } catch (e) {
        setState(() {
          text = "เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง";
        });
        dev.log('ข้อผิดพลาดระหว่างการเข้าสู่ระบบ: $e');
        _showSnackBar("เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง");
      }
    } else {
      setState(() {
        text = "กรุณากรอกอีเมลและรหัสผ่าน";
      });
      _showSnackBar("กรุณากรอกอีเมลและรหัสผ่าน");
    }
  }

  void _showSnackBar(String message) {
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
                  const SizedBox(height: 60),
                  // Logo and Welcome Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
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
                            Icons.casino,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Lotto App',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ยินดีต้อนรับสู่ระบบสลากดิจิทัล',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Login Form Card
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
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'กรุณากรอกข้อมูลเพื่อเข้าสู่ระบบ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          _buildTextField(
                            controller: emailNoCtl,
                            hintText: 'อีเมล',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildTextField(
                            controller: passNoCtl,
                            hintText: 'รหัสผ่าน',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ยังไม่มีบัญชี? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToRegister,
                          child: const Text(
                            'สมัครสมาชิก',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
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
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF7E57C2),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loginUser,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'เข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterPage(),
        ));
  }

  // void loginUser() {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const HomePage(),
  //       ));
  // }
}
