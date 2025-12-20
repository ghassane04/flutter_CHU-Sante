import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class PredictionProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Prediction> _predictions = [];
  Prediction? _selectedPrediction;
  bool _isLoading = false;
  String? _errorMessage;

  List<Prediction> get predictions => _predictions;
  Prediction? get selectedPrediction => _selectedPrediction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PredictionProvider(this._apiService);

  Future<void> fetchPredictions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _predictions = await _apiService.getPredictions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPredictionsByType(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _predictions = await _apiService.getPredictionsByType(type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPrediction(int id) async {
    try {
      _selectedPrediction = await _apiService.getPrediction(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> generatePrediction(String type, String titre, String periodePrevue) async {
    try {
      final prediction = await _apiService.generatePrediction(type, titre, periodePrevue);
      _predictions.insert(0, prediction);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPrediction(Prediction prediction) async {
    try {
      final created = await _apiService.createPrediction(prediction);
      _predictions.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePrediction(int id, Prediction prediction) async {
    try {
      final updated = await _apiService.updatePrediction(id, prediction);
      final index = _predictions.indexWhere((p) => p.id == id);
      if (index != -1) {
        _predictions[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePrediction(int id) async {
    try {
      await _apiService.deletePrediction(id);
      _predictions.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
