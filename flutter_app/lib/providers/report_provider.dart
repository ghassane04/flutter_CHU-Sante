import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class ReportProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Report> _reports = [];
  Report? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;

  List<Report> get reports => _reports;
  Report? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReportProvider(this._apiService);

  Future<void> fetchReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _apiService.getReports();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportsByType(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _apiService.getReportsByType(type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportsByPeriode(String periode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _apiService.getReportsByPeriode(periode);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectReport(int id) async {
    try {
      _selectedReport = await _apiService.getReport(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createReport(Report report) async {
    try {
      final created = await _apiService.createReport(report);
      _reports.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReport(int id, Report report) async {
    try {
      final updated = await _apiService.updateReport(id, report);
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reports[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReport(int id) async {
    try {
      await _apiService.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
