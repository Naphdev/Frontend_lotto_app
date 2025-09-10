// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class Page2 extends StatefulWidget {
  const Page2({super.key, required this.token});

  final String token;

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int selectedIndex = 0;
  String? email;
  String? _id;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    Configuration.getConfig().then(
      (value) {
        dev.log('API Endpoint: ${value['apiEndpoint']}');
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

            final List<Map<String, dynamic>> tickets =
                ticketsList.map((e) => e as Map<String, dynamic>).toList();
            return {
              'name': ticketData['name'],
              'id': ticketData['id'],
              'tickets': tickets
            };
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
      backgroundColor: Colors.grey[50], // เพิ่มสีพื้นหลังที่อ่อนนุ่ม
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2, // เพิ่ม shadow เล็กน้อย
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.confirmation_number,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'สลากของฉัน',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header Info Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'สลากดิจิทัลของคุณ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'จัดการและตรวจสอบสลากที่คุณซื้อไว้',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchLottos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    dev.log('Error: ${snapshot.error}');
                    return _buildErrorState(snapshot.error.toString());
                  } else if (!snapshot.hasData ||
                      (snapshot.data!['tickets'] as List<dynamic>).isEmpty) {
                    return _buildEmptyState();
                  } else {
                    final tickets = snapshot.data!['tickets'] as List<dynamic>;
                    return _buildTicketsList(tickets);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'กำลังโหลดสลาก...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบข้อมูลสลากกินแบ่ง',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ยังไม่มีสลากในระบบ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<dynamic> tickets) {
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index] as Map<String, dynamic>;
        final lottoNumber = ticket['LottoNumber'] as String;
        return _buildTicketCard(lottoNumber, index);
      },
    );
  }

  Widget _buildTicketCard(String lottoNumber, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.confirmation_number,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'เลขสลาก: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        lottoNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ราคา 80 บาท',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ใช้งานได้',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
