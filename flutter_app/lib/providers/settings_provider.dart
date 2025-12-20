import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class SettingsProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Setting> _settings = [];
  Setting? _selectedSetting;
  bool _isLoading = false;
  String? _errorMessage;

  List<Setting> get settings => _settings;
  Setting? get selectedSetting => _selectedSetting;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SettingsProvider(this._apiService);

  Future<void> fetchSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _apiService.getSettings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSettingsByCategorie(String categorie) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _apiService.getSettingsByCategorie(categorie);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Setting?> fetchSettingByCle(String cle) async {
    try {
      final setting = await _apiService.getSettingByCle(cle);
      return setting;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  String? getSettingValue(String cle) {
    try {
      final setting = _settings.firstWhere((s) => s.cle == cle);
      return setting.valeur;
    } catch (e) {
      return null;
    }
  }

  Future<void> selectSetting(int id) async {
    try {
      _selectedSetting = await _apiService.getSetting(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createSetting(Setting setting) async {
    try {
      final created = await _apiService.createSetting(setting);
      _settings.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSetting(int id, Setting setting) async {
    try {
      final updated = await _apiService.updateSetting(id, setting);
      final index = _settings.indexWhere((s) => s.id == id);
      if (index != -1) {
        _settings[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSetting(int id) async {
    try {
      await _apiService.deleteSetting(id);
      _settings.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
