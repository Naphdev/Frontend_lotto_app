// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_project/pages/checkpage/checkLotto2.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_project/config/config.dart';
import 'package:my_project/config/configg.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class CheckLottoPage2 extends StatefulWidget {
  const CheckLottoPage2({super.key, required this.token});

  final String token;

  @override
  State<CheckLottoPage2> createState() => _CheckLottoPage2State();
}

class _CheckLottoPage2State extends State<CheckLottoPage2> {
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
          _id = jwtDecodedToken['_id'] as String?;
          isLoading = false;
        });
        dev.log('Decoded token: ${jwtDecodedToken.toString()}');
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

  Future<List<Map<String, dynamic>>> _fetchLottos() async {
    await _decodeToken();

    if (_id == null || _id!.isEmpty) {
      throw Exception('User ID is not available');
    }

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // เพิ่ม log เพื่อตรวจสอบข้อมูลที่ส่ง
      dev.log('Sending request with userId: $_id, drawDate: $today');

      final response = await http.post(
        Uri.parse(
            'https://lotto-app-backend-h3gg.onrender.com/check-prize'), // แก้ไขจาก localhost เป็น 10.0.2.2 สำหรับ Android Emulator
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"userId": _id, "drawDate": today}),
      );

      dev.log('Response status: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        dev.log('Decoded response: $decoded'); // log decoded response

        // ตรวจสอบว่า decoded เป็น List และมี key ที่ต้องการ
        if (decoded is List && decoded.isNotEmpty) {
          // ตรวจสอบ key lottoNumber และ prize
          if (decoded.first.containsKey('lottoNumber') &&
              decoded.first.containsKey('prize')) {
            return List<Map<String, dynamic>>.from(decoded);
          } else {
            dev.log('Response format ไม่ถูกต้อง: $decoded');
            throw Exception('ข้อมูลรางวัลมีรูปแบบผิดสำหรับวัน $today');
          }
        } else {
          dev.log('ไม่พบข้อมูลรางวัลสำหรับวัน $today');
          throw Exception('ไม่พบข้อมูลรางวัลสำหรับวัน $today');
        }
      } else {
        throw Exception(
            'Failed to load lottos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error in _fetchLottos: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchWallet(dynamic prize, String num) async {
    if (_id == null || _id!.isEmpty) {
      throw Exception('User ID is not available');
    }

    try {
      final url = Uri.parse('$addwallet');
      dev.log('Requesting URL: $url');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": _id,
          "prize": prize.toString(),
          "num": num, // Use the 'num' field from your updated structure
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      dev.log('Response status: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to fetch wallet. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      dev.log('Error in _fetchWallet: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lotto', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchLottos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      dev.log('Error in FutureBuilder: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      final today =
                          DateTime.now().toIso8601String().split('T')[0];
                      dev.log('ไม่พบข้อมูลรางวัลสำหรับวัน $today');
                      return Center(
                        child: Text('ไม่พบข้อมูลรางวัลสำหรับวัน $today'),
                      );
                    } else {
                      final lottos = snapshot.data!;
                      dev.log('data: $lottos');

                      return Column(
                        children: lottos.map((lotto) {
                          return Container(
                            margin: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildLottoNumberDisplay(
                                        '${lotto['lottoNumber']}',
                                        lotto['prize']),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final num =
                                              lotto['lottoNumber'].toString();
                                          final result = await _fetchWallet(
                                              lotto['prize'], num);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'ขึ้นเงินสำเร็จ: ${result['message'] ?? ''}'),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('รางวัลนี้ไม่ถูกรางวัล'),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(20.0),
                                        minimumSize: const Size(60, 60),
                                      ),
                                      child: const Text('ขึ้นเงิน',
                                          style: TextStyle(fontSize: 20)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLottoNumberDisplay(String number, var prize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(fontSize: 30, letterSpacing: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$prize บาท',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
