import 'package:flutter/foundation.dart';
import 'package:flutter_app/services/api_service.dart';

class AIProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Map<String, String>> _conversationHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, String>> get conversationHistory => _conversationHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AIProvider(this._apiService);

  Future<String?> askQuestion(String question) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Add user question to history
    _conversationHistory.add({
      'role': 'user',
      'message': question,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    try {
      final response = await _apiService.askAI(question);
      final answer = response['answer'] ?? 'Aucune réponse reçue';
      
      // Add AI response to history
      _conversationHistory.add({
        'role': 'assistant',
        'message': answer,
        'confidence': response['confidence']?.toString() ?? '0.0',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _isLoading = false;
      notifyListeners();
      return answer;
    } catch (e) {
      _errorMessage = e.toString();
      
      // Add error message to history
      _conversationHistory.add({
        'role': 'error',
        'message': 'Erreur: ${e.toString()}',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
