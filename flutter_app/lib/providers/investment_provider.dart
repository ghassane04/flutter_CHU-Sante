import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class InvestmentProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Investment> _investments = [];
  Investment? _selectedInvestment;
  InvestmentStats? _investmentStats;
  bool _isLoading = false;
  String? _errorMessage;

  List<Investment> get investments => _investments;
  Investment? get selectedInvestment => _selectedInvestment;
  InvestmentStats? get investmentStats => _investmentStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  InvestmentProvider(this._apiService);

  Future<void> fetchInvestments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _investments = await _apiService.getInvestments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInvestmentStats() async {
    try {
      final statsData = await _apiService.getInvestmentStats();
      _investmentStats = InvestmentStats.fromJson(statsData);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectInvestment(int id) async {
    try {
      _selectedInvestment = await _apiService.getInvestment(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createInvestment(Investment investment) async {
    try {
      final created = await _apiService.createInvestment(investment);
      _investments.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInvestment(int id, Investment investment) async {
    try {
      final updated = await _apiService.updateInvestment(id, investment);
      final index = _investments.indexWhere((i) => i.id == id);
      if (index != -1) {
        _investments[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInvestment(int id) async {
    try {
      await _apiService.deleteInvestment(id);
      _investments.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
