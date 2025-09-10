// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lotto_app/pages/checkpage/checkLotto2.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

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
        dev.log('API Endpoint: ${value['apiEndpoint']}');
      },
    );
    CheckLottoPage2(token: widget.token);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),

              // Content Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title Section
                      _buildTitleSection(),

                      // Tickets List
                      Expanded(
                        child: _buildTicketsList(),
                      ),

                      // Check Button
                      _buildCheckButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'สลากของฉัน',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'สลากดิจิทัล',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'สลากที่คุณซื้อไว้',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchLottos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData ||
            (snapshot.data!['tickets'] as List<dynamic>).isEmpty) {
          return _buildEmptyState();
        } else {
          final tickets = snapshot.data!['tickets'] as List<dynamic>;
          return _buildTicketsGrid(tickets);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          SizedBox(height: 16),
          Text(
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
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
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีสลาก',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ไปซื้อสลากก่อนตรวจรางวัลกันเถอะ!',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsGrid(List<dynamic> tickets) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index] as Map<String, dynamic>;
          final lottoNumber = ticket['LottoNumber'] as String;
          return _buildTicketCard(lottoNumber, index);
        },
      ),
    );
  }

  Widget _buildTicketCard(String lottoNumber, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[50]!,
            Colors.purple[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number,
            color: Colors.blue[600],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'เลขสลาก',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lottoNumber,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckLottoPage2(token: widget.token),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF667eea).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 24),
            const SizedBox(width: 12),
            const Text(
              'ตรวจรางวัล',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
