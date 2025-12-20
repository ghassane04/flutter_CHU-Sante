import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/models/index.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8085/api';
  
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add interceptor for token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure token is loaded
          if (_token == null) {
            await _loadToken();
          }
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, logout
            logout();
          }
          return handler.next(error);
        },
      ),
    );

    // Initial token load
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  // ==================== AUTH ====================

  Future<JwtResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      final jwtResponse = JwtResponse.fromJson(response.data);
      _token = jwtResponse.token;
      await _saveToken(jwtResponse.token);
      return jwtResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<MessageResponse> signup(SignupRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: request.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;

  // ==================== PATIENTS ====================

  Future<List<Patient>> getPatients() async {
    try {
      final response = await _dio.get('/patients');
      final List<dynamic> data = response.data;
      return data.map((item) => Patient.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      rethrow;
    }
  }

  Future<Patient> getPatient(int id) async {
    try {
      final response = await _dio.get('/patients/$id');
      return Patient.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching patient: $e');
      rethrow;
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await _dio.post(
        '/patients',
        data: patient.toJson(),
      );
      return Patient.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating patient: $e');
      rethrow;
    }
  }

  Future<Patient> updatePatient(int id, Patient patient) async {
    try {
      final response = await _dio.put(
        '/patients/$id',
        data: patient.toJson(),
      );
      return Patient.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating patient: $e');
      rethrow;
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await _dio.delete('/patients/$id');
    } catch (e) {
      debugPrint('Error deleting patient: $e');
      rethrow;
    }
  }

  // ==================== SERVICES ====================

  Future<List<MedicalService>> getServices() async {
    try {
      final response = await _dio.get('/services');
      final List<dynamic> data = response.data;
      return data.map((item) => MedicalService.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
      rethrow;
    }
  }

  Future<MedicalService> getService(int id) async {
    try {
      final response = await _dio.get('/services/$id');
      return MedicalService.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching service: $e');
      rethrow;
    }
  }

  Future<MedicalService> createService(MedicalService service) async {
    try {
      final response = await _dio.post(
        '/services',
        data: service.toJson(),
      );
      return MedicalService.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating service: $e');
      rethrow;
    }
  }

  Future<MedicalService> updateService(int id, MedicalService service) async {
    try {
      final response = await _dio.put(
        '/services/$id',
        data: service.toJson(),
      );
      return MedicalService.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await _dio.delete('/services/$id');
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }

  // ==================== SEJOURS ====================

  Future<List<Sejour>> getSejours() async {
    try {
      final response = await _dio.get('/sejours');
      final List<dynamic> data = response.data;
      return data.map((item) => Sejour.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching sejours: $e');
      rethrow;
    }
  }

  Future<List<Sejour>> getSejoursEnCours() async {
    try {
      final response = await _dio.get('/sejours/en-cours');
      final List<dynamic> data = response.data;
      return data.map((item) => Sejour.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching sejours en cours: $e');
      rethrow;
    }
  }

  Future<int> getSejoursEnCoursCount() async {
    try {
      final response = await _dio.get('/sejours/count/en-cours');
      return response.data['count'] ?? 0;
    } catch (e) {
      debugPrint('Error fetching sejours count: $e');
      rethrow;
    }
  }

  Future<Sejour> getSejour(int id) async {
    try {
      final response = await _dio.get('/sejours/$id');
      return Sejour.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching sejour: $e');
      rethrow;
    }
  }

  Future<Sejour> createSejour(Sejour sejour) async {
    try {
      final response = await _dio.post(
        '/sejours',
        data: sejour.toJson(),
      );
      return Sejour.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating sejour: $e');
      rethrow;
    }
  }

  Future<Sejour> updateSejour(int id, Sejour sejour) async {
    try {
      final response = await _dio.put(
        '/sejours/$id',
        data: sejour.toJson(),
      );
      return Sejour.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating sejour: $e');
      rethrow;
    }
  }

  Future<void> deleteSejour(int id) async {
    try {
      await _dio.delete('/sejours/$id');
    } catch (e) {
      debugPrint('Error deleting sejour: $e');
      rethrow;
    }
  }

  // ==================== ACTES MEDICAUX ====================

  Future<List<ActeMedical>> getActesMedicaux() async {
    try {
      final response = await _dio.get('/actes');
      final List<dynamic> data = response.data;
      return data.map((item) => ActeMedical.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching actes medicaux: $e');
      rethrow;
    }
  }

  Future<ActeMedical> getActeMedical(int id) async {
    try {
      final response = await _dio.get('/actes/$id');
      return ActeMedical.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching acte medical: $e');
      rethrow;
    }
  }

  Future<List<ActeMedical>> getActesMedicauxBySejour(int sejourId) async {
    try {
      final response = await _dio.get('/actes/sejour/$sejourId');
      final List<dynamic> data = response.data;
      return data.map((item) => ActeMedical.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching actes medicaux by sejour: $e');
      rethrow;
    }
  }

  Future<ActeMedical> createActeMedical(ActeMedical acte) async {
    try {
      final response = await _dio.post(
        '/actes',
        data: acte.toJson(),
      );
      return ActeMedical.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating acte medical: $e');
      rethrow;
    }
  }

  Future<ActeMedical> updateActeMedical(int id, ActeMedical acte) async {
    try {
      final response = await _dio.put(
        '/actes/$id',
        data: acte.toJson(),
      );
      return ActeMedical.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating acte medical: $e');
      rethrow;
    }
  }

  Future<void> deleteActeMedical(int id) async {
    try {
      await _dio.delete('/actes/$id');
    } catch (e) {
      debugPrint('Error deleting acte medical: $e');
      rethrow;
    }
  }

  // ==================== DASHBOARD ====================

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Future<List<ActesByTypeStats>> getActesByType() async {
    try {
      final response = await _dio.get('/dashboard/actes-by-type');
      final List<dynamic> data = response.data;
      return data.map((item) => ActesByTypeStats.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching actes by type: $e');
      rethrow;
    }
  }

  Future<List<RevenusByMonthStats>> getRevenusByMonth() async {
    try {
      final response = await _dio.get('/dashboard/revenus-by-month');
      final List<dynamic> data = response.data;
      return data.map((item) => RevenusByMonthStats.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching revenues by month: $e');
      rethrow;
    }
  }

  Future<List<SejoursByServiceStats>> getSejoursByService() async {
    try {
      final response = await _dio.get('/dashboard/sejours-by-service');
      final List<dynamic> data = response.data;
      return data.map((item) => SejoursByServiceStats.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching sejours by service: $e');
      rethrow;
    }
  }

  // ==================== PREDICTIONS ====================

  Future<List<Prediction>> getPredictions() async {
    try {
      final response = await _dio.get('/predictions');
      final List<dynamic> data = response.data;
      return data.map((item) => Prediction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching predictions: $e');
      rethrow;
    }
  }

  Future<Prediction> getPrediction(int id) async {
    try {
      final response = await _dio.get('/predictions/$id');
      return Prediction.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching prediction: $e');
      rethrow;
    }
  }

  Future<List<Prediction>> getPredictionsByType(String type) async {
    try {
      final response = await _dio.get('/predictions/type/$type');
      final List<dynamic> data = response.data;
      return data.map((item) => Prediction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching predictions by type: $e');
      rethrow;
    }
  }

  Future<Prediction> generatePrediction(String type, String titre, String periodePrevue) async {
    try {
      final response = await _dio.post(
        '/predictions/generate',
        data: {'type': type, 'titre': titre, 'periodePrevue': periodePrevue},
      );
      return Prediction.fromJson(response.data);
    } catch (e) {
      debugPrint('Error generating prediction: $e');
      rethrow;
    }
  }

  Future<Prediction> createPrediction(Prediction prediction) async {
    try {
      final response = await _dio.post(
        '/predictions',
        data: prediction.toJson(),
      );
      return Prediction.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating prediction: $e');
      rethrow;
    }
  }

  Future<Prediction> updatePrediction(int id, Prediction prediction) async {
    try {
      final response = await _dio.put(
        '/predictions/$id',
        data: prediction.toJson(),
      );
      return Prediction.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating prediction: $e');
      rethrow;
    }
  }

  Future<void> deletePrediction(int id) async {
    try {
      await _dio.delete('/predictions/$id');
    } catch (e) {
      debugPrint('Error deleting prediction: $e');
      rethrow;
    }
  }

  // ==================== INVESTMENTS ====================

  Future<List<Investment>> getInvestments() async {
    try {
      final response = await _dio.get('/investments');
      final List<dynamic> data = response.data;
      return data.map((item) => Investment.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching investments: $e');
      rethrow;
    }
  }

  Future<Investment> getInvestment(int id) async {
    try {
      final response = await _dio.get('/investments/$id');
      return Investment.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching investment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInvestmentStats() async {
    try {
      final response = await _dio.get('/investments/stats');
      return response.data;
    } catch (e) {
      debugPrint('Error fetching investment stats: $e');
      rethrow;
    }
  }

  Future<Investment> createInvestment(Investment investment) async {
    try {
      final response = await _dio.post(
        '/investments',
        data: investment.toJson(),
      );
      return Investment.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating investment: $e');
      rethrow;
    }
  }

  Future<Investment> updateInvestment(int id, Investment investment) async {
    try {
      final response = await _dio.put(
        '/investments/$id',
        data: investment.toJson(),
      );
      return Investment.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating investment: $e');
      rethrow;
    }
  }

  Future<void> deleteInvestment(int id) async {
    try {
      await _dio.delete('/investments/$id');
    } catch (e) {
      debugPrint('Error deleting investment: $e');
      rethrow;
    }
  }

  // ==================== ALERTS ====================

  Future<List<Alert>> getAlerts() async {
    try {
      final response = await _dio.get('/alerts');
      final List<dynamic> data = response.data;
      return data.map((item) => Alert.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      rethrow;
    }
  }

  Future<Alert> getAlert(int id) async {
    try {
      final response = await _dio.get('/alerts/$id');
      return Alert.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching alert: $e');
      rethrow;
    }
  }

  Future<List<Alert>> getUnreadAlerts() async {
    try {
      final response = await _dio.get('/alerts/non-lues');
      final List<dynamic> data = response.data;
      return data.map((item) => Alert.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching unread alerts: $e');
      rethrow;
    }
  }

  Future<List<Alert>> getUnresolvedAlerts() async {
    try {
      final response = await _dio.get('/alerts/non-resolues');
      final List<dynamic> data = response.data;
      return data.map((item) => Alert.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching unresolved alerts: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAlertStats() async {
    try {
      final response = await _dio.get('/alerts/stats');
      return response.data;
    } catch (e) {
      debugPrint('Error fetching alert stats: $e');
      rethrow;
    }
  }

  Future<Alert> markAlertAsRead(int id) async {
    try {
      final response = await _dio.put('/alerts/$id/lire');
      return Alert.fromJson(response.data);
    } catch (e) {
      debugPrint('Error marking alert as read: $e');
      rethrow;
    }
  }

  Future<Alert> markAlertAsResolved(int id) async {
    try {
      final response = await _dio.put('/alerts/$id/resoudre');
      return Alert.fromJson(response.data);
    } catch (e) {
      debugPrint('Error marking alert as resolved: $e');
      rethrow;
    }
  }

  Future<Alert> createAlert(Alert alert) async {
    try {
      final response = await _dio.post(
        '/alerts',
        data: alert.toJson(),
      );
      return Alert.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating alert: $e');
      rethrow;
    }
  }

  Future<Alert> updateAlert(int id, Alert alert) async {
    try {
      final response = await _dio.put(
        '/alerts/$id',
        data: alert.toJson(),
      );
      return Alert.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating alert: $e');
      rethrow;
    }
  }

  Future<void> deleteAlert(int id) async {
    try {
      await _dio.delete('/alerts/$id');
    } catch (e) {
      debugPrint('Error deleting alert: $e');
      rethrow;
    }
  }

  // ==================== REPORTS ====================

  Future<List<Report>> getReports() async {
    try {
      final response = await _dio.get('/reports');
      final List<dynamic> data = response.data;
      return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      rethrow;
    }
  }

  Future<Report> getReport(int id) async {
    try {
      final response = await _dio.get('/reports/$id');
      return Report.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching report: $e');
      rethrow;
    }
  }

  Future<List<Report>> getReportsByType(String type) async {
    try {
      final response = await _dio.get('/reports/type/$type');
      final List<dynamic> data = response.data;
      return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching reports by type: $e');
      rethrow;
    }
  }

  Future<List<Report>> getReportsByPeriode(String periode) async {
    try {
      final response = await _dio.get('/reports/periode/$periode');
      final List<dynamic> data = response.data;
      return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching reports by periode: $e');
      rethrow;
    }
  }

  Future<Report> createReport(Report report) async {
    try {
      final response = await _dio.post(
        '/reports',
        data: report.toJson(),
      );
      return Report.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating report: $e');
      rethrow;
    }
  }

  Future<Report> updateReport(int id, Report report) async {
    try {
      final response = await _dio.put(
        '/reports/$id',
        data: report.toJson(),
      );
      return Report.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(int id) async {
    try {
      await _dio.delete('/reports/$id');
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }

  // ==================== SETTINGS ====================

  Future<List<Setting>> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      final List<dynamic> data = response.data;
      return data.map((item) => Setting.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      rethrow;
    }
  }

  Future<Setting> getSetting(int id) async {
    try {
      final response = await _dio.get('/settings/$id');
      return Setting.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching setting: $e');
      rethrow;
    }
  }

  Future<Setting> getSettingByCle(String cle) async {
    try {
      final response = await _dio.get('/settings/cle/$cle');
      return Setting.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching setting by cle: $e');
      rethrow;
    }
  }

  Future<List<Setting>> getSettingsByCategorie(String categorie) async {
    try {
      final response = await _dio.get('/settings/categorie/$categorie');
      final List<dynamic> data = response.data;
      return data.map((item) => Setting.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching settings by categorie: $e');
      rethrow;
    }
  }

  Future<Setting> createSetting(Setting setting) async {
    try {
      final response = await _dio.post(
        '/settings',
        data: setting.toJson(),
      );
      return Setting.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating setting: $e');
      rethrow;
    }
  }

  Future<Setting> updateSetting(int id, Setting setting) async {
    try {
      final response = await _dio.put(
        '/settings/$id',
        data: setting.toJson(),
      );
      return Setting.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating setting: $e');
      rethrow;
    }
  }

  Future<void> deleteSetting(int id) async {
    try {
      await _dio.delete('/settings/$id');
    } catch (e) {
      debugPrint('Error deleting setting: $e');
      rethrow;
    }
  }

  // ==================== AI ASSISTANT ====================

  Future<Map<String, dynamic>> askAI(String question) async {
    try {
      final response = await _dio.post(
        '/ai/ask',
        data: {'question': question},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error asking AI: $e');
      rethrow;
    }
  }

  // ==================== MEDECINS ====================

  Future<List<Medecin>> getMedecins() async {
    try {
      final response = await _dio.get('/medecins');
      final List<dynamic> data = response.data;
      return data.map((item) => Medecin.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching medecins: $e');
      rethrow;
    }
  }

  Future<Medecin> getMedecin(int id) async {
    try {
      final response = await _dio.get('/medecins/$id');
      return Medecin.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching medecin: $e');
      rethrow;
    }
  }

  Future<List<Medecin>> getMedecinsByService(int serviceId) async {
    try {
      final response = await _dio.get('/medecins/service/$serviceId');
      final List<dynamic> data = response.data;
      return data.map((item) => Medecin.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching medecins by service: $e');
      rethrow;
    }
  }

  Future<Medecin> createMedecin(Medecin medecin) async {
    try {
      final response = await _dio.post(
        '/medecins',
        data: medecin.toJson(),
      );
      return Medecin.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating medecin: $e');
      rethrow;
    }
  }

  Future<Medecin> updateMedecin(int id, Medecin medecin) async {
    try {
      final response = await _dio.put(
        '/medecins/$id',
        data: medecin.toJson(),
      );
      return Medecin.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating medecin: $e');
      rethrow;
    }
  }

  Future<void> deleteMedecin(int id) async {
    try {
      await _dio.delete('/medecins/$id');
    } catch (e) {
      debugPrint('Error deleting medecin: $e');
      rethrow;
    }
  }

  // ==================== USERS ====================

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      final List<dynamic> data = response.data;
      return data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      rethrow;
    }
  }

  Future<User> getUser(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '/users',
        data: userData,
      );
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '/users/$id',
        data: userData,
      );
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  Future<List<Role>> getRoles() async {
    try {
      final response = await _dio.get('/roles');
      final List<dynamic> data = response.data;
      return data.map((item) => Role.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching roles: $e');
      rethrow;
    }
  }
}

