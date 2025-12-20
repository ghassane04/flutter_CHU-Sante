import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class ActeMedicalProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<ActeMedical> _actes = [];
  List<ActeMedical> _selectedSejourActes = [];
  ActeMedical? _selectedActe;
  String? _error;
  bool _isLoading = false;

  ActeMedicalProvider(this._apiService);

  // Getters
  List<ActeMedical> get actes => _actes;
  List<ActeMedical> get selectedSejourActes => _selectedSejourActes;
  ActeMedical? get selectedActe => _selectedActe;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get all actes medicaux
  Future<void> loadActesMedicaux() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _actes = await _apiService.getActesMedicaux();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get actes by sejour
  Future<void> loadActesMedicauxBySejour(int sejourId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSejourActes = await _apiService.getActesMedicauxBySejour(sejourId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single acte medical
  Future<void> loadActeMedical(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedActe = await _apiService.getActeMedical(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create acte medical
  Future<bool> createActeMedical(ActeMedical acte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newActe = await _apiService.createActeMedical(acte);
      _actes.add(newActe);
      _selectedSejourActes.add(newActe);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update acte medical
  Future<bool> updateActeMedical(int id, ActeMedical acte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedActe = await _apiService.updateActeMedical(id, acte);
      final index = _actes.indexWhere((a) => a.id == id);
      if (index != -1) {
        _actes[index] = updatedActe;
      }
      final indexSejour = _selectedSejourActes.indexWhere((a) => a.id == id);
      if (indexSejour != -1) {
        _selectedSejourActes[indexSejour] = updatedActe;
      }
      _selectedActe = updatedActe;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete acte medical
  Future<bool> deleteActeMedical(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteActeMedical(id);
      _actes.removeWhere((a) => a.id == id);
      _selectedSejourActes.removeWhere((a) => a.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearSelection() {
    _selectedActe = null;
    _selectedSejourActes = [];
    _error = null;
    notifyListeners();
  }
}
