import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'package:lotto_app/pages/checkpage/checkLotto.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:lotto_app/pages/paypage/searchLotto.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class Page3 extends StatefulWidget {
  const Page3({super.key, required this.token});

  final String token;

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  int selectedIndex = 2;
  String? email;
  String? _id;
  String? nameU;
  String? myToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
        final url = value['apiEndpoint'];
      },
    );
  }

  Future<void> _decodeToken() async {
    try {
      if (widget.token.isNotEmpty) {
        final Map<String, dynamic> jwtDecodedToken =
            JwtDecoder.decode(widget.token);
        setState(() {
          email = jwtDecodedToken['email'] as String?;
          _id = jwtDecodedToken['_id'] as String?; // แยก
          isLoading = false;
        });
        // dev.log('Response data: $nameU');
        dev.log('Decoded token: ${jwtDecodedToken.toString()}');
        // dev.log('Email: $email');
        // dev.log('_id: $_id');
      } else {
        setState(() {
          email = 'No token provided';
          _id = null;
          isLoading = false;
        });

        dev.log('No token provided.');
      }
    } catch (e) {
      setState(() {
        email = 'Error decoding token';
        _id = null;
        isLoading = false;
      });
      dev.log('Error decoding token: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchLottos() async {
    await _decodeToken();

    if (_id == null || _id!.isEmpty) {
      throw Exception('User ID is not available');
    }

    try {
      final response = await http.get(Uri.parse('$users$_id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // dev.log('Received data: $data');

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final usersData = data['data'];

          if (usersData is Map<String, dynamic>) {
            return usersData;
          } else {
            throw Exception('Invalid data format: "data" is not a map');
          }
        } else {
          throw Exception('Invalid data format: no key "data"');
        }
      } else {
        throw Exception(
            'Failed to load. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

//=========================================db======================

                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchLottos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      } else {
                        if (snapshot.hasData) {
                          final usersName = snapshot.data!;
                          final nameUser = usersName['name'] ??
                              'Unknown User'; // Provide a default value

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                nameUser,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        } else {
                          return Text('No data available');
                        }
                      }
                    },
                  ),

//=========================================db======================

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        email ?? 'No email provided',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: logOutUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void logOutUser() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const loginPage(),
        ));
  }
}
