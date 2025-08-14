// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_project/pages/checkpage/checkLotto2.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_project/config/config.dart';
import 'package:my_project/config/configg.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:my_project/pages/navpages/another.dart';
import 'package:my_project/pages/navpages/mylotto.dart';

class CheckLottoPage extends StatefulWidget {
  const CheckLottoPage({super.key, required this.token});

  final String token;

  @override
  State<CheckLottoPage> createState() => _CheckLottoPageState();
}

class _CheckLottoPageState extends State<CheckLottoPage> {
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
    CheckLottoPage2(token: widget.token ?? '');
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
        dev.log('Response data: $nameU');
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
    if (_id == null || _id!.isEmpty) {
      throw Exception('User ID is not available');
    }

    try {
      final response = await http.get(Uri.parse('$ticket$_id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        dev.log('Received data: $data');

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final ticketData = data['data'];

          if (ticketData is Map<String, dynamic> &&
              ticketData.containsKey('tickets')) {
            final List<dynamic> ticketsList = ticketData['tickets'];

            if (ticketsList is List<dynamic>) {
              final List<Map<String, dynamic>> tickets =
                  ticketsList.map((e) => e as Map<String, dynamic>).toList();
              return {
                'name': ticketData['name'],
                'id': ticketData['id'],
                'tickets': tickets
              };
            } else {
              throw Exception('Invalid data format: "tickets" is not a list');
            }
          } else {
            throw Exception('Invalid data format: no key "tickets"');
          }
        } else {
          throw Exception('Invalid data format: no key "data"');
        }
      } else {
        throw Exception(
            'Failed to load lottos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lottos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // สีพื้นหลังเหมือนในภาพ
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
          },
        ),
      ),
      body: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min, // ให้คอลัมน์มีขนาดเล็กที่สุดเพื่อให้เนื้อหาอยู่ตรงกลาง
          children: [
            // เพิ่ม title Lotto
            const Text(
              'Lotto',
              style: TextStyle(
                fontSize: 32, // ขนาดใหญ่เพื่อให้ชัดเจน
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // ตัวเลขล็อตโต้ที่ใหญ่และยาวขึ้น

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchLottos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    dev.log('Error: ${snapshot.error}');
                    return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      (snapshot.data!['tickets'] as List<dynamic>).isEmpty) {
                    return const Center(child: Text('ไม่พบข้อมูลสลากกินแบ่ง'));
                  } else {
                    final tickets = snapshot.data!['tickets'] as List<dynamic>;

                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index] as Map<String, dynamic>;
                        final lottoNumber = ticket['LottoNumber'] as String;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 7.0,
                                color: Colors.black,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Lotto Number: $lottoNumber',
                                    style: const TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),

            // const SizedBox(height: 10),
            // ปุ่มตรวจสลาก
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  // นำทางไปยังหน้า CheckLottoPage2
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckLottoPage2(token: widget.token ?? ''),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    'ตรวจสลากดิจิทัล',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottoNumberDisplay(String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.8, // ขนาดยาวขึ้น 80% ของความกว้างหน้าจอ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 30.0, vertical: 30.0), // ขนาด padding ใหญ่ขึ้น
          child: Text(
            number,
            textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
            style: const TextStyle(
                fontSize: 40, // ขนาดใหญ่ขึ้น
                letterSpacing: 8,
                fontWeight: FontWeight.w700 // ช่องว่างระหว่างตัวอักษรเพิ่มขึ้น
                ),
          ),
        ),
      ),
    );
  }
}
