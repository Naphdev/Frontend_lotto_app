// ignore_for_file: camel_case_types, use_build_context_synchronously, sort_child_properties_last, non_constant_identifier_names, unused_element

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

// import 'package:lotto_app/pages/home.dart';
import 'package:my_project/config/config.dart';
import 'package:my_project/config/configg.dart';
import 'package:my_project/pages/home.dart';
import 'package:my_project/pages/reg.dart';
import 'package:my_project/pages/adminpages/admin1.dart';
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
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFD1C4E9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    const Text(
                      'Lotto',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Welcome onboard!',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: emailNoCtl,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: passNoCtl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginUser,
                        child: const Text('Login',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: _navigateToRegister,
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                                color: Color(0xFF7E57C2),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
