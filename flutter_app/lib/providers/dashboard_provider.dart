import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  DashboardStats? _stats;
  List<ActesByTypeStats> _actesByType = [];
  List<RevenusByMonthStats> _revenusByMonth = [];
  List<SejoursByServiceStats> _sejoursByService = [];
  String? _error;
  bool _isLoading = false;

  DashboardProvider(this._apiService);

  // Getters
  DashboardStats? get stats => _stats;
  List<ActesByTypeStats> get actesByType => _actesByType;
  List<RevenusByMonthStats> get revenusByMonth => _revenusByMonth;
  List<SejoursByServiceStats> get sejoursByService => _sejoursByService;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getDashboardStats(),
        _apiService.getActesByType(),
        _apiService.getRevenusByMonth(),
        _apiService.getSejoursByService(),
      ], eagerError: true);

      _stats = results[0] as DashboardStats;
      _actesByType = results[1] as List<ActesByTypeStats>;
      _revenusByMonth = results[2] as List<RevenusByMonthStats>;
      _sejoursByService = results[3] as List<SejoursByServiceStats>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _stats = null;
    _actesByType = [];
    _revenusByMonth = [];
    _sejoursByService = [];
    _error = null;
    notifyListeners();
  }
}
