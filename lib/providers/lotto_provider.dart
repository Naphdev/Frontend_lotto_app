import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'package:lotto_app/config/configg.dart' as config;
import 'package:lotto_app/services/api_service.dart';

class LottoProvider with ChangeNotifier {
  List<Map<String, dynamic>> _availableLottos = [];
  List<Map<String, dynamic>> _userTickets = [];
  Map<String, dynamic>? _winningNumbers;
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  // Getters
  List<Map<String, dynamic>> get availableLottos => _availableLottos;
  List<Map<String, dynamic>> get userTickets => _userTickets;
  Map<String, dynamic>? get winningNumbers => _winningNumbers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  // Set offline status
  void setOfflineStatus(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  // Fetch available lottos
  Future<void> fetchAvailableLottos() async {
    if (_isOffline) {
      _setError('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      return;
    }

    _setLoading(true);
    try {
      final data = await ApiService.get(config.lottos);

      if (data.containsKey('data')) {
        final lottoItems = data['data'];
        if (lottoItems is List) {
          _availableLottos = lottoItems.map((item) {
            return item as Map<String, dynamic>;
          }).toList();
          _clearError();
        } else {
          throw Exception('Invalid data format: items is not a list');
        }
      } else {
        throw Exception('Invalid data format: no key "data"');
      }
    } catch (e) {
      _setError('ไม่สามารถโหลดข้อมูลสลากได้: $e');
      dev.log('Error fetching available lottos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user tickets
  Future<void> fetchUserTickets(String userId) async {
    if (_isOffline) {
      _setError('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      return;
    }

    _setLoading(true);
    try {
      final data = await ApiService.get('${config.ticket}$userId');

      if (data.containsKey('data')) {
        final ticketData = data['data'];
        if (ticketData is Map<String, dynamic> &&
            ticketData.containsKey('tickets')) {
          final List<dynamic> ticketsList = ticketData['tickets'];
          _userTickets =
              ticketsList.map((e) => e as Map<String, dynamic>).toList();
          _clearError();
        } else {
          throw Exception('Invalid data format: no key "tickets"');
        }
      } else {
        throw Exception('Invalid data format: no key "data"');
      }
    } catch (e) {
      _setError('ไม่สามารถโหลดข้อมูลสลากของฉันได้: $e');
      dev.log('Error fetching user tickets: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch winning numbers
  Future<void> fetchWinningNumbers() async {
    if (_isOffline) {
      _setError('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      return;
    }

    _setLoading(true);
    try {
      final data = await ApiService.get(config.winning);

      if (data.containsKey('data')) {
        final lottoItems = data['data'];
        if (lottoItems != null && lottoItems is List && lottoItems.isNotEmpty) {
          _winningNumbers = lottoItems.first as Map<String, dynamic>;
          _clearError();
        } else {
          throw Exception('No winning numbers available');
        }
      } else {
        throw Exception('Invalid data format: no key "data"');
      }
    } catch (e) {
      _setError('ไม่สามารถโหลดข้อมูลรางวัลได้: $e');
      dev.log('Error fetching winning numbers: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Buy lotto ticket
  Future<bool> buyLottoTicket(String userId, String lottoNumber) async {
    if (_isOffline) {
      _setError('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      return false;
    }

    _setLoading(true);
    try {
      final result = await ApiService.post(
        config.buyLotto,
        body: {
          'userId': userId,
          'lottoNumber': lottoNumber,
        },
      );

      if (result['status'] == true) {
        _clearError();
        // Refresh user tickets after successful purchase
        await fetchUserTickets(userId);
        return true;
      } else {
        _setError(result['message'] ?? 'ไม่สามารถซื้อสลากได้');
        return false;
      }
    } catch (e) {
      _setError('เกิดข้อผิดพลาดในการซื้อสลาก: $e');
      dev.log('Error buying lotto ticket: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check prizes
  Future<List<Map<String, dynamic>>> checkPrizes(
      String userId, String drawDate) async {
    if (_isOffline) {
      _setError('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      return [];
    }

    try {
      final decoded = await ApiService.post(
        config.winn,
        body: {"userId": userId, "drawDate": drawDate},
      );

      if (decoded is List && decoded.isNotEmpty) {
        final firstItem = decoded[0];
        if (firstItem is Map<String, dynamic> &&
            firstItem.containsKey('lottoNumber') &&
            firstItem.containsKey('prize')) {
          final List<Map<String, dynamic>> result = [];
          for (int i = 0; i < decoded.length; i++) {
            final item = decoded[i];
            if (item is Map<String, dynamic>) {
              result.add(item);
            }
          }
          return result;
        } else {
          throw Exception('ข้อมูลรางวัลมีรูปแบบผิด');
        }
      } else {
        throw Exception('ไม่พบข้อมูลรางวัล');
      }
    } catch (e) {
      _setError('เกิดข้อผิดพลาดในการตรวจสอบรางวัล: $e');
      dev.log('Error checking prizes: $e');
      return [];
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _availableLottos.clear();
    _userTickets.clear();
    _winningNumbers = null;
    _clearError();
    notifyListeners();
  }
}
