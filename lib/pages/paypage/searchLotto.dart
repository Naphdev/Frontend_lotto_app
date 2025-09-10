import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/config/configg.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class SearchLotto extends StatefulWidget {
  const SearchLotto({super.key, required this.token});

  final String token;

  @override
  _SearchLottoState createState() => _SearchLottoState();
}

class _SearchLottoState extends State<SearchLotto> {
  Future<List<Map<String, dynamic>>> _lottosFuture = Future.value([]);
  String url = '';
  String text = "";
  String? email;
  String? _id;
  String nameU = '';
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
          _id = jwtDecodedToken['_id'] as String?; // แยก
          isLoading = false;
        });
        dev.log('Decoded token: ${jwtDecodedToken.toString()}');
        // dev.log('Email: $email');
        // dev.log('_id: $url');
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

  Future<void> _buyLotto(String lottoNumber) async {
    if (_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$buyLotto'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': _id,
          'lottoNumber': lottoNumber,
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status']) {
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
                    'ซื้อสลากเลข $lottoNumber สำเร็จ!',
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
          ),
        );
        // รีเฟรชข้อมูลเพื่ออัปเดตสถานะ
        setState(() {
          _lottosFuture =
              _fetchLottos(_searchQuery.isNotEmpty ? _searchQuery : null);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] ?? 'เกิดข้อผิดพลาดในการซื้อสลาก',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLottos([String? lottoNumber]) async {
    try {
      final Uri uri = lottoNumber != null && lottoNumber.isNotEmpty
          ? Uri.parse('$lottoSearch$lottoNumber')
          : Uri.parse('$lottos');

      dev.log('Fetching from: $uri');

      final response = await http.get(uri);

      dev.log('Response status: ${response.statusCode}');
      dev.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final lottoItems = data['data'];
            if (lottoItems != null) {
              if (lottoItems is List) {
                return List<Map<String, dynamic>>.from(lottoItems);
              } else if (lottoItems is Map<String, dynamic>) {
                // ในกรณีที่ค้นหาเลขเฉพาะ อาจได้ข้อมูลเพียงรายการเดียว
                return [lottoItems];
              }
            }
            throw Exception(
                'Invalid data format: data is null or not in expected format');
          } else if (data.containsKey('status') && data['status'] == false) {
            // กรณีที่ API ส่งกลับ status: false (เช่น ไม่พบสลาก)
            throw Exception(data['message'] ?? 'ไม่พบสลากที่ค้นหา');
          } else {
            throw Exception('Invalid data format: no key "data"');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        if (lottoNumber != null && lottoNumber.isNotEmpty) {
          throw Exception('เลข $lottoNumber ขายแล้วหรือไม่มีในระบบ');
        } else {
          throw Exception('ไม่พบสลากที่ค้นหา');
        }
      } else {
        throw Exception('Failed to load lottos: HTTP ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error in _fetchLottos: $e');
      throw Exception('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกเลขสลากที่ต้องการค้นหา'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (query.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เลขสลากต้องมี 6 หลัก'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _searchQuery = query;
      _lottosFuture = _fetchLottos(_searchQuery);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _lottosFuture = _fetchLottos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'ซื้อสลากกินแบ่ง',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7E57C2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.casino,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "สลากกินแบ่งรัฐบาล",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "เลือกเลขที่คุณต้องการ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Search Section
          Container(
            margin: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E57C2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF7E57C2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "ค้นหาเลขสลาก",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          hintText: 'กรอกเลขสลาก 6 หลัก',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF7E57C2),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xFF7E57C2),
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'ค้นหา',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E57C2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ผลการค้นหา: $_searchQuery',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7E57C2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: Colors.grey,
                        ),
                        label: const Text(
                          'ล้าง',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7E57C2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.list_alt,
                            color: Color(0xFF7E57C2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'ผลการค้นหา'
                              : 'สลากทั้งหมด',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _lottosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF7E57C2)),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${snapshot.error}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _lottosFuture = _fetchLottos(
                                          _searchQuery.isNotEmpty
                                              ? _searchQuery
                                              : null);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E57C2),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('ลองใหม่'),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'ไม่พบสลากเลข $_searchQuery ที่ซื้อได้'
                                      : 'ไม่พบข้อมูลสลาก',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _clearSearch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7E57C2),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('ดูสลากทั้งหมด'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final lotto = snapshot.data![index];
                              return _buildLottoCard(lotto);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottoCard(Map<String, dynamic> lotto) {
    // ตรวจสอบสถานะของสลาก
    final int amount = lotto['Amount'] ?? 0;
    final bool isAvailable = amount > 0;
    final bool isSold = amount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSold
              ? [Colors.grey[100]!, Colors.grey[200]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSold ? Colors.grey[300]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSold ? 0.02 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Lotto Number
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSold
                    ? LinearGradient(
                        colors: [Colors.grey[400]!, Colors.grey[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF7E57C2), Color(0xFF9575CD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lotto['LottoNumber'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSold ? Colors.grey[200] : Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Lotto Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'เลขสลาก',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSold) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ขายแล้ว',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lotto['LottoNumber'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSold ? Colors.grey[400] : const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 16,
                        color:
                            isSold ? Colors.grey[400] : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lotto['Price']} บาท',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSold
                              ? Colors.grey[400]
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Buy Button
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      _buyLotto(lotto['LottoNumber']);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSold ? Colors.grey[300] : const Color(0xFF4CAF50),
                foregroundColor: isSold ? Colors.grey[500] : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isSold ? 0 : 2,
              ),
              child: Text(
                isSold ? 'ขายแล้ว' : 'ซื้อ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSold ? Colors.grey[500] : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LottoNumberInput extends StatefulWidget {
  final Function(String) onChanged;

  const LottoNumberInput({Key? key, required this.onChanged}) : super(key: key);

  @override
  _LottoNumberInputState createState() => _LottoNumberInputState();
}

class _LottoNumberInputState extends State<LottoNumberInput> {
  List<String> numbers = ['', '', '', '', '', ''];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) => _buildNumberBox(index)),
    );
  }

  Widget _buildNumberBox(int index) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            numbers[index] = value;
            widget.onChanged(numbers.join());
          });
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
