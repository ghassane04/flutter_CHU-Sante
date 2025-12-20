import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<MedicalService> _services = [];
  MedicalService? _selectedService;
  String? _error;
  bool _isLoading = false;

  ServiceProvider(this._apiService);

  // Getters
  List<MedicalService> get services => _services;
  MedicalService? get selectedService => _selectedService;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get all services
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _apiService.getServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single service
  Future<void> loadService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedService = await _apiService.getService(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create service
  Future<bool> createService(MedicalService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newService = await _apiService.createService(service);
      _services.add(newService);
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

  // Update service
  Future<bool> updateService(int id, MedicalService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedService = await _apiService.updateService(id, service);
      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        _services[index] = updatedService;
      }
      _selectedService = updatedService;
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

  // Delete service
  Future<bool> deleteService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteService(id);
      _services.removeWhere((s) => s.id == id);
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
    _selectedService = null;
    _error = null;
    notifyListeners();
  }
}
