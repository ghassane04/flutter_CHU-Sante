import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class MedecinProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Medecin> _medecins = [];
  Medecin? _selectedMedecin;
  bool _isLoading = false;
  String? _errorMessage;

  List<Medecin> get medecins => _medecins;
  Medecin? get selectedMedecin => _selectedMedecin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedecinProvider(this._apiService);

  Future<void> fetchMedecins() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _medecins = await _apiService.getMedecins();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMedecinsByService(int serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _medecins = await _apiService.getMedecinsByService(serviceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectMedecin(int id) async {
    try {
      _selectedMedecin = await _apiService.getMedecin(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createMedecin(Medecin medecin) async {
    try {
      final created = await _apiService.createMedecin(medecin);
      _medecins.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedecin(int id, Medecin medecin) async {
    try {
      final updated = await _apiService.updateMedecin(id, medecin);
      final index = _medecins.indexWhere((m) => m.id == id);
      if (index != -1) {
        _medecins[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMedecin(int id) async {
    try {
      await _apiService.deleteMedecin(id);
      _medecins.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
