import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'package:lotto_app/pages/checkpage/checkLotto.dart';
import 'package:lotto_app/pages/paypage/searchLotto.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class Page1 extends StatefulWidget {
  const Page1({super.key, required this.token});

  final String token;

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  Future<List<Map<String, dynamic>>> _lottosFuture = Future.value([]);
  String url = '';
  String text = "";
  String? email;
  String? _id;
  String? myToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    Configuration.getConfig().then(
      (value) {
        dev.log(value['apiEndpoint']);
        url = value['apiEndpoint'];
      },
    );
    _lottosFuture = _fetchLottos();
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

  Future<Map<String, dynamic>> _fetchUser() async {
    await _decodeToken();

    if (_id == null || _id!.isEmpty) {
      throw Exception('User ID is not available');
    }

    try {
      final response = await http.get(Uri.parse('$users$_id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final userData = data['data'];
          if (userData is Map<String, dynamic> &&
              userData.containsKey('wallet')) {
            final wallet = userData['wallet'];
            if (wallet is Map<String, dynamic>) {
              if (wallet['Balance'] is int) {
                wallet['Balance'] = wallet['Balance'].toString();
              }
              return wallet;
            } else {
              throw Exception('Invalid wallet data format');
            }
          } else {
            throw Exception('Invalid user data format: no wallet information');
          }
        } else {
          throw Exception('Invalid data format: no key "data"');
        }
      } else {
        throw Exception(
            'Failed to load user data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error in _fetchUser: $e');
      throw Exception('Failed to load user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLottos() async {
    try {
      final response = await http.get(Uri.parse(winning));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final lottoItems = data['data'];
          if (lottoItems != null && lottoItems is List) {
            return lottoItems.map((item) {
              if (item is Map<String, dynamic>) {
                // Convert string to int if needed
                item['LottoWin'] =
                    int.tryParse(item['LottoWin'].toString()) ?? 0;
                item['FirstPrize'] =
                    int.tryParse(item['FirstPrize'].toString()) ?? 0;
                item['SecondPrize'] =
                    int.tryParse(item['SecondPrize'].toString()) ?? 0;
                item['ThirdPrize'] =
                    int.tryParse(item['ThirdPrize'].toString()) ?? 0;
                item['FourthPrize'] =
                    int.tryParse(item['FourthPrize'].toString()) ?? 0;
                item['FifthPrize'] =
                    int.tryParse(item['FifthPrize'].toString()) ?? 0;
                return item;
              } else {
                throw Exception('Invalid item format');
              }
            }).toList();
          } else {
            throw Exception('Invalid data format: items is null or not a list');
          }
        } else {
          throw Exception('Invalid data format: no key "data"');
        }
      } else {
        throw Exception('Failed to load lottos: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lottos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Lotto App',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF7E57C2),
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } else {
                      final wallet = snapshot.data!;
                      return Text(
                        '\$${wallet['Balance']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.casino,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ยินดีต้อนรับสู่ระบบสลากดิจิทัล",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ลุ้นรางวัลใหญ่กับสลากดิจิทัล",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "ซื้อสลาก",
                      Icons.shopping_cart,
                      const Color(0xFF4CAF50),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchLotto(token: widget.token),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      "ตรวจสลาก",
                      Icons.search,
                      const Color(0xFF2196F3),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckLottoPage(token: widget.token),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ผลรางวัลสลาก",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "งวดล่าสุด",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "LIVE",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results Content
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _lottosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF7E57C2)),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'เกิดข้อผิดพลาด: ${snapshot.error}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'ไม่พบข้อมูลสลากกินแบ่ง',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else {
                          final lottos = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFirstPrize(lottos[0]['LottoWin']),
                              const SizedBox(height: 20),
                              _buildOtherPrizes(lottos[0])
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Check Lotto Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckLottoPage(token: widget.token),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "ตรวจสลากดิจิทัล",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'สลากของฉัน'),
      //     BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'อื่นๆ'),
      //   ],
      //   currentIndex: 0,
      //   onTap: (int index) {
      //     // Add navigation logic here
      //   },
      // ),
    );
  }
}

Widget _buildFirstPrize(int winningNumber) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFFFF8C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: const Color(0xFFFFD700).withOpacity(0.2),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'รางวัลที่ 1',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                '10,000 \$',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Winning Number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'หมายเลขที่ถูกรางวัล',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  winningNumber.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Prize Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'รางวัลสูงสุด 10,000 บาท',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildOtherPrizes(Map<String, dynamic> lottoData) {
  return Column(
    children: [
      // Section Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF7E57C2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.stars,
              color: Color(0xFF7E57C2),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'รางวัลอื่นๆ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7E57C2),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Prizes Grid
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          String title;
          String prize;
          String winningNumber;
          IconData icon;

          switch (index) {
            case 0:
              title = 'รางวัลที่ 2';
              prize = '8,000 \$';
              winningNumber = lottoData['SecondPrize'].toString();
              icon = Icons.emoji_events;
              break;
            case 1:
              title = 'รางวัลที่ 3';
              prize = '6,000 \$';
              winningNumber = lottoData['ThirdPrize'].toString();
              icon = Icons.emoji_events;
              break;
            case 2:
              title = 'รางวัลที่ 4';
              prize = '4,000 \$';
              winningNumber = lottoData['FourthPrize'].toString();
              icon = Icons.emoji_events;
              break;
            case 3:
              title = 'รางวัลที่ 5';
              prize = '2,000 \$';
              winningNumber = lottoData['FifthPrize'].toString();
              icon = Icons.emoji_events;
              break;
            default:
              title = '';
              prize = '';
              winningNumber = '';
              icon = Icons.emoji_events;
          }

          return _buildPrizeItem(title, prize, winningNumber, icon);
        },
      ),
    ],
  );
}

Widget _buildPrizeItem(
    String title, String prize, String winningNumber, IconData icon) {
  Color prizeColor;
  switch (title) {
    case 'รางวัลที่ 2':
      prizeColor = const Color(0xFFC0C0C0); // Silver
      break;
    case 'รางวัลที่ 3':
      prizeColor = const Color(0xFFCD7F32); // Bronze
      break;
    case 'รางวัลที่ 4':
      prizeColor = const Color(0xFF4CAF50); // Green
      break;
    case 'รางวัลที่ 5':
      prizeColor = const Color(0xFF2196F3); // Blue
      break;
    default:
      prizeColor = const Color(0xFF7E57C2); // Purple
  }

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [prizeColor, prizeColor.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: prizeColor.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon and Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Prize Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            prize,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Winning Number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            winningNumber,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(
    String title, IconData icon, Color color, VoidCallback onTap) {
  return Container(
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
