import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  String? _error;
  bool _isLoading = false;

  PatientProvider(this._apiService);

  // Getters
  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get all patients
  Future<void> loadPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patients = await _apiService.getPatients();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single patient
  Future<void> loadPatient(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPatient = await _apiService.getPatient(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create patient
  Future<bool> createPatient(Patient patient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPatient = await _apiService.createPatient(patient);
      _patients.add(newPatient);
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

  // Update patient
  Future<bool> updatePatient(int id, Patient patient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPatient = await _apiService.updatePatient(id, patient);
      final index = _patients.indexWhere((p) => p.id == id);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }
      _selectedPatient = updatedPatient;
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

  // Delete patient
  Future<bool> deletePatient(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deletePatient(id);
      _patients.removeWhere((p) => p.id == id);
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
    _selectedPatient = null;
    _error = null;
    notifyListeners();
  }
}
