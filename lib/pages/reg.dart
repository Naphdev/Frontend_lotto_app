// ignore_for_file: use_build_context_synchronously, unused_field, sort_child_properties_last

import 'dart:developer' as dev;
import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:http/http.dart' as http;



import 'package:my_project/config/config.dart';
import 'package:my_project/config/configg.dart';
import 'package:my_project/pages/login.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          navigateToLogin();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed. Please try again.')),
          );
        }
      } catch (e) {
        dev.log("Error during registration: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    } else {
      setState(() {
        _isNotValidata = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
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
            colors: [Color(0xFFE1E4F9), Color(0xFFF2F2F9)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const SizedBox(height: 20),
                  const Text(
                    'Lotto',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Welcome onboard!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField('Enter your fullname', nameNoCtl),
                  const SizedBox(height: 20),
                  _buildTextField('Enter your Email', emailNoCtl),
                  const SizedBox(height: 20),
                  _buildTextField('Enter your Phone', phoneNoCtl),
                  const SizedBox(height: 20),
                  _buildTextField('Enter your Password', passNoCtl,
                      obscureText: true),
                  const SizedBox(height: 20),
                  _buildTextField('Confirm Password', confpassNoCtl,
                      obscureText: true),
                  const SizedBox(height: 30),
                  _buildButton('Register', registerUser, isPrimary: true),
                  const SizedBox(height: 15),
                  _buildButton('Sign In', navigateToLogin, isPrimary: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF8064A2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 5,
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
}
