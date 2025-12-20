import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class SejourProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Sejour> _sejours = [];
  List<Sejour> _sejoursEnCours = [];
  Sejour? _selectedSejour;
  String? _error;
  bool _isLoading = false;

  SejourProvider(this._apiService);

  // Getters
  List<Sejour> get sejours => _sejours;
  List<Sejour> get sejoursEnCours => _sejoursEnCours;
  Sejour? get selectedSejour => _selectedSejour;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get all sejours
  Future<void> loadSejours() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sejours = await _apiService.getSejours();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get sejours en cours
  Future<void> loadSejoursEnCours() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sejoursEnCours = await _apiService.getSejoursEnCours();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single sejour
  Future<void> loadSejour(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSejour = await _apiService.getSejour(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create sejour
  Future<bool> createSejour(Sejour sejour) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSejour = await _apiService.createSejour(sejour);
      _sejours.add(newSejour);
      if (newSejour.statut == 'EN_COURS') {
        _sejoursEnCours.add(newSejour);
      }
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

  // Update sejour
  Future<bool> updateSejour(int id, Sejour sejour) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedSejour = await _apiService.updateSejour(id, sejour);
      final index = _sejours.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sejours[index] = updatedSejour;
      }
      final indexEnCours = _sejoursEnCours.indexWhere((s) => s.id == id);
      if (updatedSejour.statut == 'EN_COURS') {
        if (indexEnCours == -1) {
          _sejoursEnCours.add(updatedSejour);
        } else {
          _sejoursEnCours[indexEnCours] = updatedSejour;
        }
      } else if (indexEnCours != -1) {
        _sejoursEnCours.removeAt(indexEnCours);
      }
      _selectedSejour = updatedSejour;
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

  // Delete sejour
  Future<bool> deleteSejour(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteSejour(id);
      _sejours.removeWhere((s) => s.id == id);
      _sejoursEnCours.removeWhere((s) => s.id == id);
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
    _selectedSejour = null;
    _error = null;
    notifyListeners();
  }
}
