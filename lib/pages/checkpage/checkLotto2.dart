// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  Set<String> _claimedLottos = {}; // เก็บเลขสลากที่ขึ้นเงินแล้ว

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _loadClaimedLottos();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
      },
    );
  }

  Future<void> _loadClaimedLottos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final claimedList = prefs.getStringList('claimed_lottos_$_id') ?? [];
      setState(() {
        _claimedLottos = claimedList.toSet();
      });
    } catch (e) {
      dev.log('Error loading claimed lottos: $e');
    }
  }

  Future<void> _saveClaimedLottos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('claimed_lottos_$_id', _claimedLottos.toList());
    } catch (e) {
      dev.log('Error saving claimed lottos: $e');
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
              // Custom Header
              Container(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ตรวจรางวัล',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ตรวจสอบผลรางวัลสลากของคุณ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Header Section
                          Container(
                            width: double.infinity,
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
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'ผลการตรวจรางวัล',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Lottery Results
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchLottos(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingState();
                              } else if (snapshot.hasError) {
                                dev.log(
                                    'Error in FutureBuilder: ${snapshot.error}');
                                return _buildErrorState(
                                    snapshot.error.toString());
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return _buildEmptyState();
                              } else {
                                final lottos = snapshot.data!;
                                dev.log('data: $lottos');
                                return Column(
                                  children: lottos.map((lotto) {
                                    final lottoNumber =
                                        lotto['lottoNumber'].toString();
                                    final isClaimed =
                                        _claimedLottos.contains(lottoNumber);
                                    return _buildLottoCard(lotto, isClaimed);
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'กำลังตรวจสอบผลรางวัล...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
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
    final today = DateTime.now().toIso8601String().split('T')[0];
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบข้อมูลรางวัล',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ไม่พบข้อมูลรางวัลสำหรับวัน $today',
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

  Widget _buildLottoCard(Map<String, dynamic> lotto, bool isClaimed) {
    final lottoNumber = lotto['lottoNumber'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: isClaimed
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: isClaimed
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isClaimed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '✓ ได้รับรางวัลแล้ว',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildLottoNumberDisplay(
                    lottoNumber,
                    lotto['prize'],
                    isClaimed,
                  ),
                ),
                const SizedBox(width: 16),
                _buildClaimButton(lotto),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton(Map<String, dynamic> lotto) {
    final lottoNumber = lotto['lottoNumber'].toString();
    final isClaimed = _claimedLottos.contains(lottoNumber);

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 90,
        maxHeight: 90,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isClaimed
                ? Colors.grey.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isClaimed
            ? null
            : () async {
                await _claimPrize(lotto);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isClaimed ? Colors.grey[400] : Colors.green,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16.0),
          minimumSize: const Size(70, 70),
          maximumSize: const Size(90, 90),
          elevation: isClaimed ? 0 : 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isClaimed ? Icons.check_circle : Icons.monetization_on,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              isClaimed ? 'ได้รับแล้ว' : 'รับรางวัล',
              style: TextStyle(
                fontSize: isClaimed ? 10 : 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimPrize(Map<String, dynamic> lotto) async {
    final lottoNumber = lotto['lottoNumber'].toString();

    // ตรวจสอบว่าขึ้นเงินแล้วหรือยัง
    if (_claimedLottos.contains(lottoNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สลากนี้ได้รับรางวัลไปแล้ว'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // แสดง loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _fetchWallet(lotto['prize'], lottoNumber);

      // ปิด loading dialog
      Navigator.of(context).pop();

      // เพิ่มเลขสลากลงในรายการที่ขึ้นเงินแล้ว
      setState(() {
        _claimedLottos.add(lottoNumber);
      });

      // บันทึกสถานะการขึ้นเงิน
      await _saveClaimedLottos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ยินดีด้วย! คุณได้รับรางวัล ${lotto['prize']} บาท',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
    } catch (e) {
      // ปิด loading dialog
      Navigator.of(context).pop();

      // ตรวจสอบประเภทของ error
      String errorMessage = e.toString();
      Color backgroundColor = Colors.red;
      IconData icon = Icons.error;

      // ตรวจสอบว่าเป็น error เกี่ยวกับรางวัลหรือไม่
      if (errorMessage.contains('Prize amount must be greater than zero') ||
          errorMessage.contains('Prize amount must b greater than zero') ||
          errorMessage.contains('400') ||
          errorMessage.contains('Bad Request')) {
        errorMessage = 'เสียใจด้วย สลากเลข $lottoNumber ไม่ถูกรางวัลในงวดนี้';
        backgroundColor = Colors.orange;
        icon = Icons.sentiment_dissatisfied;
      } else if (errorMessage.contains('Insufficient funds')) {
        errorMessage = 'ยอดเงินในบัญชีไม่เพียงพอสำหรับการขึ้นเงิน';
        backgroundColor = Colors.red;
        icon = Icons.account_balance_wallet;
      } else if (errorMessage.contains('Lotto not found')) {
        errorMessage = 'ไม่พบข้อมูลสลากในระบบ';
        backgroundColor = Colors.red;
        icon = Icons.search_off;
      } else if (errorMessage.contains('Wallet not found')) {
        errorMessage = 'ไม่พบบัญชีเงินในระบบ';
        backgroundColor = Colors.red;
        icon = Icons.account_balance_wallet;
      } else if (errorMessage.contains('ไม่พบข้อมูลรางวัลสำหรับวัน')) {
        errorMessage = 'ยังไม่มีผลรางวัลสำหรับวันนี้ กรุณาลองใหม่ในภายหลัง';
        backgroundColor = Colors.blue;
        icon = Icons.schedule;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildLottoNumberDisplay(String number, var prize, bool isClaimed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isClaimed
            ? LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              )
            : const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
        borderRadius: BorderRadius.circular(16),
        border: isClaimed ? Border.all(color: Colors.green, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isClaimed
                ? Colors.green.withOpacity(0.2)
                : const Color(0xFF667eea).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number,
                color: isClaimed ? Colors.grey[600] : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'เลขสลาก',
                style: TextStyle(
                  fontSize: 14,
                  color: isClaimed ? Colors.grey[600] : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 28,
              letterSpacing: 6,
              color: isClaimed ? Colors.grey[700] : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isClaimed ? Colors.grey[200] : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: isClaimed ? Colors.grey[600] : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$prize บาท',
                  style: TextStyle(
                    fontSize: 16,
                    color: isClaimed ? Colors.grey[600] : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isClaimed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'CLAIMED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
