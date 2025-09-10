import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lotto_app/pages/login.dart';
import 'package:lotto_app/pages/adminpages/admin2.dart';

class Admin1 extends StatefulWidget {
  final int? cid;
  final String? token;

  const Admin1({Key? key, this.cid, this.token}) : super(key: key);

  @override
  _Admin1State createState() => _Admin1State();
}

class _Admin1State extends State<Admin1> {
  int _selectedIndex = 0;
  List<dynamic> _lottoData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllLottos();
  }

  // Function to fetch all lotto data
  Future<void> _fetchAllLottos() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://lotto-app-backend-h3gg.onrender.com/lottos';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          setState(() {
            _lottoData = jsonResponse['data'];
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load lotto data');
      }
    } catch (e) {
      print('Error fetching lotto data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to fetch sold lotto data
  Future<void> _fetchSoldLottos() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://lotto-app-backend-h3gg.onrender.com/sold-lotto';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          setState(() {
            _lottoData = jsonResponse['data'];
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load sold lotto data');
      }
    } catch (e) {
      print('Error fetching sold lotto data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function for toggle button changes
  void _onToggle(int index) {
    setState(() {
      _selectedIndex = index;
      _lottoData = []; // Clear previous data
      if (index == 0) {
        _fetchAllLottos(); // Fetch all lotto data
      } else {
        _fetchSoldLottos(); // Fetch sold lotto data
      }
    });
  }

  void _navigateToAdmin2() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Admin2()),
    );
  }

  Future<void> _resetSystem() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการรีเซ็ทระบบ'),
          content: Text(
              'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ทระบบ? การกระทำนี้จะทำให้ Account User ทั้งหมดถูกลบและตั้งค่าใหม่'),
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
    );

    // If user confirmed, proceed with the reset
    if (confirmed == true) {
      final url = 'https://lotto-app-backend-h3gg.onrender.com/resetU';
      try {
        final response = await http.post(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ระบบรีเซ็ทเรียบร้อยแล้ว')),
            );
            // Optionally, refresh the lotto data or navigate to another screen
            _fetchAllLottos(); // Refresh the lotto data
          } else {
            throw Exception('Failed to reset system');
          }
        } else {
          throw Exception('Failed to reset system');
        }
      } catch (e) {
        print('Error resetting system: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ระบบรีเซ็ทเรียบร้อยแล้ว')),
        );
      }
    }
  }

  Future<void> _resetLotto() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการรีเซ็ทระบบ'),
          content: Text(
              'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ทระบบ? การกระทำนี้จะทำให้ Account User ทั้งหมดถูกลบและตั้งค่าใหม่'),
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
    );

    // If user confirmed, proceed with the reset
    if (confirmed == true) {
      final url = 'https://lotto-app-backend-h3gg.onrender.com/c-lotto';
      try {
        final response = await http.post(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ระบบรีเซ็ทเรียบร้อยแล้ว')),
            );
            // Optionally, refresh the lotto data or navigate to another screen
            _fetchAllLottos(); // Refresh the lotto data
          } else {
            throw Exception('Failed to reset system');
          }
        } else {
          throw Exception('Failed to reset system');
        }
      } catch (e) {
        print('Error resetting system: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ระบบรีเซ็ทเรียบร้อยแล้ว')),
        );
      }
    }
  }

  void _handleLogout() {
    // Here you can add any logout logic, such as clearing user data or token
    // For now, we'll just navigate to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              loginPage()), // Replace LoginPage() with your actual login page widget
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("แอดมิน", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ToggleButtons(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("ทั้งหมด"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("ขายแล้ว"),
                    ),
                  ],
                  isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                  onPressed: _onToggle, // Call _onToggle on button press
                  borderRadius: BorderRadius.circular(20),
                  selectedColor: Colors.white,
                  fillColor: Colors.purple[200],
                  color: Colors.black,
                ),
                SizedBox(height: 16),
                Text("สลาก งวดวันที่ 16 มิ.ย 2558"),
                Divider(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _lottoData.length,
                    itemBuilder: (context, index) {
                      final lotto = _lottoData[index];
                      return LotteryItem(
                        number: lotto['LottoNumber'],
                        price: '${lotto['Price']} บาท',
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _resetSystem, // Call _resetSystem on button press
              child: Text('รีเซ็ทระบบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: _resetLotto, // Call _resetSystem on button press
              child: Text('รีเซ็ท Lotto/Random'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
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
        onTap: (index) {
          if (index == 1) {
            _navigateToAdmin2();
          } else if (index == 2) {
            _handleLogout(); // Call the logout method when "ออกระบบ" is tapped
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}

class LotteryItem extends StatelessWidget {
  final String number;
  final String price;

  LotteryItem({required this.number, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("สลากกินแบ่ง", style: TextStyle(fontSize: 14)),
              Text(number,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text(price, style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                child: Text('เลือก'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
