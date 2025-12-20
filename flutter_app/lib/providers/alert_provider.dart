import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class AlertProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Alert> _alerts = [];
  Alert? _selectedAlert;
  Map<String, dynamic>? _alertStats;
  bool _isLoading = false;
  String? _errorMessage;

  List<Alert> get alerts => _alerts;
  Alert? get selectedAlert => _selectedAlert;
  Map<String, dynamic>? get alertStats => _alertStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AlertProvider(this._apiService);

  Future<void> fetchAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _apiService.getAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _apiService.getUnreadAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnresolvedAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await _apiService.getUnresolvedAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAlertStats() async {
    try {
      _alertStats = await _apiService.getAlertStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectAlert(int id) async {
    try {
      _selectedAlert = await _apiService.getAlert(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final updated = await _apiService.markAlertAsRead(id);
      final index = _alerts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _alerts[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsResolved(int id) async {
    try {
      final updated = await _apiService.markAlertAsResolved(id);
      final index = _alerts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _alerts[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createAlert(Alert alert) async {
    try {
      final created = await _apiService.createAlert(alert);
      _alerts.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAlert(int id, Alert alert) async {
    try {
      final updated = await _apiService.updateAlert(id, alert);
      final index = _alerts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _alerts[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAlert(int id) async {
    try {
      await _apiService.deleteAlert(id);
      _alerts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
