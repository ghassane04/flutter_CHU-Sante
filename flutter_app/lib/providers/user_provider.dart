import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<User> _users = [];
  User? _selectedUser;
  List<Role> _roles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider(this._apiService);

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _apiService.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoles() async {
    try {
      _roles = await _apiService.getRoles();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectUser(int id) async {
    try {
      _selectedUser = await _apiService.getUser(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final created = await _apiService.createUser(userData);
      _users.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final updated = await _apiService.updateUser(id, userData);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _apiService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
