import 'package:flutter/material.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/models/index.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  JwtResponse? _currentUser;
  String? _error;
  bool _isLoading = false;

  AuthProvider(this._apiService);

  // Getters
  JwtResponse? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _apiService.isAuthenticated;

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        LoginRequest(username: username, password: password),
      );
      _currentUser = response;
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

  // Signup
  Future<bool> signup(SignupRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.signup(request);
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

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    await _apiService.logout();
    notifyListeners();
  }
}
