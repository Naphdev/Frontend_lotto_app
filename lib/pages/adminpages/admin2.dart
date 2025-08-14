import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_project/pages/adminpages/admin1.dart';
import 'package:my_project/pages/login.dart';

class Admin2 extends StatefulWidget {
  @override
  _Admin2State createState() => _Admin2State();
}

class _Admin2State extends State<Admin2> {
  bool _isLoading = false;
  Map<String, dynamic> _lotteryResult = {};
  int _selectedIndex = 0; // Track selected index for the bottom navigation bar

  @override
  void initState() {
    super.initState();
    _fetchWinningData();
  }

  Future<void> _fetchWinningData() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://b-lotto.onrender.com/winning';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final drawDateObj = jsonResponse['data'][0]['DrawDate'];
          print(
              'DrawDate from API: $drawDateObj'); // log ดูวันที่ที่ backend ส่งมา
          setState(() {
            _lotteryResult = jsonResponse['data'][0];
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load winning data');
      }
    } catch (e) {
      print('Error fetching winning data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _randomizePrizes() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://lotto-app-backend-h3gg.onrender.com/randomWin';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          setState(() {
            _lotteryResult = jsonResponse['data'][0];
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to randomize prizes');
      }
    } catch (e) {
      print('Error randomizing prizes: $e');
      setState(() {
        _isLoading = false;
      });
    }
    _fetchWinningData();
  }

  Future<void> _resetPrizes() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://b-lotto.onrender.com/resetWin';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          setState(() {
            _lotteryResult.clear(); // Clear the prize data
            _isLoading = false;
          });
          Future.delayed(Duration(milliseconds: 100), () {
            _showResetDialog();
            _fetchWinningData();
          });
        } else {
          throw Exception('Failed to reset prizes');
        }
      } else {
        throw Exception('Failed to reset prizes');
      }
    } catch (e) {
      print('Error resetting prizes: $e');
      setState(() {
        _isLoading = false;
      });
    }
    _fetchWinningData();
  }

  Future<void> _resetAllTickets() async {
    final confirmed = await _showConfirmationDialog();
    if (confirmed) {
      setState(() {
        _isLoading = true;
      });

      final url = 'https://b-lotto.onrender.com/delAllT';
      try {
        final response = await http.post(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == true) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ตั๋วทั้งหมดถูกรีเซ็ตเรียบร้อยแล้ว'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            throw Exception('Failed to reset all tickets');
          }
        } else {
          throw Exception('Failed to reset all tickets');
        }
      } catch (e) {
        print('Error resetting all tickets: $e');
        setState(() {
          _isLoading = false;
        });
      }
      _fetchWinningData();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ยืนยันการรีเซ็ต'),
              content: Text('คุณต้องการรีเซ็ตตั๋วทั้งหมดหรือไม่?'),
              actions: <Widget>[
                TextButton(
                  child: Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('ยืนยัน'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('สำเร็จ'),
          content: Text('รางวัลถูกรีเซ็ตเรียบร้อยแล้ว'),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onBottomNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Admin1()), // Navigate to Admin1
        );
        break;
      case 1:
        // No action needed, already on Admin2
        break;
      case 2:
        _handleLogout();
        break;
    }
  }

  void _handleLogout() {
    // เพิ่มโลจิกการ logout ที่นี่ (ถ้าจำเป็น) เช่น การล้างข้อมูลผู้ใช้หรือโทเค็น

    // นำผู้ใช้กลับไปยังหน้า login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => loginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ผลสลากลอตเตอรี่'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Displaying draw date
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _lotteryResult.isNotEmpty
                            ? _lotteryResult['DrawDate'] ?? ''
                            : 'ยังไม่มีข้อมูลรางวัล', // Show empty state
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Prize 1 section
                    _lotteryResult.isNotEmpty
                        ? _buildPrizeCard(
                            title: 'รางวัลที่ 1',
                            number: _lotteryResult['FirstPrize'].toString(),
                            amount: '10,000 บาท')
                        : SizedBox.shrink(),
                    SizedBox(height: 10),
                    // Other prize sections
                    _lotteryResult.isNotEmpty
                        ? Column(
                            children: [
                              LotteryResultItem(
                                  prize: 'รางวัลที่ 2',
                                  number:
                                      _lotteryResult['SecondPrize'].toString(),
                                  amount: '8,000 บาท'),
                              LotteryResultItem(
                                  prize: 'รางวัลที่ 3',
                                  number:
                                      _lotteryResult['ThirdPrize'].toString(),
                                  amount: '6,000 บาท'),
                              LotteryResultItem(
                                  prize: 'รางวัลที่ 4',
                                  number:
                                      _lotteryResult['FourthPrize'].toString(),
                                  amount: '4,000 บาท'),
                              LotteryResultItem(
                                  prize: 'รางวัลที่ 5',
                                  number:
                                      _lotteryResult['FifthPrize'].toString(),
                                  amount: '2,000 บาท'),
                            ],
                          )
                        : Center(child: Text('ยังไม่มีรางวัลที่แสดง')),
                    SizedBox(height: 20),
                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _resetAllTickets,
                          child: Text('รีเซ็ตตั๋วทั้งหมด(Tickets)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle:
                                TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _randomizePrizes,
                              child: Text('สุ่มรางวัล'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _resetPrizes,
                              child: Text('รีเซ็ตรางวัล'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'สุ่มสลาก'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'ออกระบบ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[200],
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavBarTap,
      ),
    );
  }

  Widget _buildPrizeCard(
      {required String title, required String number, required String amount}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          Text(
            number,
            style: TextStyle(fontSize: 40, color: Colors.red),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class LotteryResultItem extends StatelessWidget {
  final String prize;
  final String number;
  final String amount;

  LotteryResultItem(
      {required this.prize, required this.number, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prize, style: TextStyle(fontSize: 16)),
          Text(number,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(amount, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
