import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:my_project/config/config.dart';
import 'package:my_project/config/configg.dart';
import 'package:my_project/pages/checkpage/checkLotto.dart';
import 'package:my_project/pages/navpages/another.dart';
import 'package:my_project/pages/navpages/mylotto.dart';
import 'package:my_project/pages/paypage/searchLotto.dart';
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
    SearchLotto(token: widget.token ?? '');
    CheckLottoPage(token: widget.token ?? '');
    Page2(token: widget.token ?? '');
    Page3(token: widget.token ?? '');
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
              item['LottoWin'] = int.tryParse(item['LottoWin'].toString()) ?? 0;
              item['FirstPrize'] = int.tryParse(item['FirstPrize'].toString()) ?? 0;
              item['SecondPrize'] = int.tryParse(item['SecondPrize'].toString()) ?? 0;
              item['ThirdPrize'] = int.tryParse(item['ThirdPrize'].toString()) ?? 0;
              item['FourthPrize'] = int.tryParse(item['FourthPrize'].toString()) ?? 0;
              item['FifthPrize'] = int.tryParse(item['FifthPrize'].toString()) ?? 0;
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
      appBar: AppBar(
        title: const Text('Lotto'),
        backgroundColor: Colors.grey[300],
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.black),
                const SizedBox(width: 5),
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    } else {
                      final wallet = snapshot.data!;
                      return Text(
                        '\$${wallet['Balance']}',
                        style: const TextStyle(color: Colors.black),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const Text(
            //   "งวดวันที่ xx/xx/xxxx",
            //   style: TextStyle(fontSize: 16),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(30),
              child: const Icon(Icons.casino, size: 80),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SearchLotto(token: widget.token ?? '')), // ระบุหน้าใหม่
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("ซื้อสลากดิจิทัล"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "ผลรางวัลสลาก",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // children: [
              //   Text("งวดวันที่ xx/xx/xxxx", style: TextStyle(fontSize: 16)),
              // ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _lottosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('ไม่พบข้อมูลสลากกินแบ่ง'));
                  } else {
                    final lottos = snapshot.data!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // _buildFirstPrize(lottos.isNotEmpty ? lottos[0]['LottoWin'] : 'N/A'),
                            _buildFirstPrize(lottos[0]['LottoWin']),
                            const SizedBox(height: 10),
                            _buildOtherPrizes(lottos[0])
                            
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CheckLottoPage(token: widget.token ?? '')), // นำทางไปยังหน้า checkLotto
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.grey[200], // สีของปุ่ม
              ),
              child: const Text(
                "ตรวจสลากดิจิทัล",
                style: TextStyle(color: Colors.black),
              ),
            ),
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
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รางวัลที่ 1',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '10,000 \$',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              winningNumber.toString(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildOtherPrizes(Map<String, dynamic> lottoData) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    ),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 4, // For now, let's display 4 other prizes
    itemBuilder: (context, index) {
      String title;
      String prize;
      String winningNumber;

      switch (index) {
        case 0:
          title = 'รางวัลที่ 2';
          prize = ' 8000 \$';
          winningNumber = lottoData['SecondPrize'].toString();
          break;
        case 1:
          title = 'รางวัลที่ 3';
          prize = '6000 \$';
          winningNumber = lottoData['ThirdPrize'].toString();
          break;
        case 2:
          title = 'รางวัลที่ 4';
          prize = '4000 \$';
          winningNumber = lottoData['FourthPrize'].toString();
          break;
        case 3:
          title = 'รางวัลที่ 5';
          prize = '2000 \$';
          winningNumber = lottoData['FifthPrize'].toString();
          break;
        default:
          title = '';
          prize = '';
          winningNumber = '';
      }

      return _buildPrizeItem(title, prize, winningNumber);
    },
  );
}

Widget _buildPrizeItem(String title, String prize, String winningNumber) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              prize,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          winningNumber,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
