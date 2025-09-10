// ignore_for_file: prefer_const_constructors, unused_element, use_super_parameters, unused_import

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lotto_app/pages/navpages/another.dart';
import 'package:lotto_app/pages/navpages/homePage.dart';
import 'package:lotto_app/pages/navpages/mylotto.dart';

class HomePage extends StatefulWidget {
  final int? cid;
  final String? token;

  const HomePage({Key? key, this.cid, this.token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? email;
  int selectedIndex = 0;
  Widget currentPage = const SizedBox(); // Initialize with a placeholder widget

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token!);
      email = jwtDecodedToken['email'] as String?;
    }
    // Set initial page with token
    currentPage = Page1(token: widget.token ?? '');
    // Page2(token: widget.token ?? '');
    // Page3(token: widget.token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Home'),
        automaticallyImplyLeading: false,
        // actions: [_buildBackButton()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner), label: 'My Tickets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
            if (selectedIndex == 0) {
              currentPage = Page1(token: widget.token ?? '');
            } else if (selectedIndex == 1) {
              currentPage = Page2(token: widget.token ?? '');
            } else if (selectedIndex == 2) {
              currentPage = Page3(token: widget.token ?? '');
            }
          });
        },
      ),
      body: currentPage,
    );

    // body: Center(
    // child: Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Text('Welcome to Home Page'),
    //     SizedBox(height: 20),
    //     Text('CID: ${widget.cid ?? "Not provided"}'),
    //     Text('Token: ${widget.token ?? "Not provided"}'),
    //     Text('Email: ${email ?? "Not provided"}'),
    //   ],
    // ),
    //   ),
    // );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
