import React, { useState, useEffect } from 'react';
import { Send, Bot, TrendingUp, DollarSign, AlertCircle, BarChart3 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { aiService } from '../services/aiService';
import { api } from '../services/api';

interface Message {
  id: number;
  type: 'user' | 'assistant';
  text: string;
  time: string;
  confidence?: number;
}

const suggestions = [
  'Quels sont les revenus totaux actuels ?',
  'Combien de patients avons-nous ?',
  'Analyse des services médicaux',
  'Statistiques des séjours en cours',
  'Résumé des actes médicaux',
  'Quelles sont les tendances actuelles ?',
];

export function AIAssistant() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      type: 'assistant',
      text: '👋 Bonjour ! Je suis votre assistant IA pour l\'analyse des données hospitalières.\n\n💡 **Fonctionnalités**:\n- Analyse des données en temps réel\n- Statistiques patients, services, séjours\n- Prédictions avec IA (nécessite configuration)\n\n🔑 Pour activer l\'IA avancée, configurez votre clé API OpenAI dans `.env.local`\n\nComment puis-je vous aider ?',
      time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
      confidence: 1.0
    },
  ]);
  const [inputText, setInputText] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [stats, setStats] = useState<any>(null);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const data = await api.getDashboardStats();
      setStats(data);
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  const handleSendMessage = async (text: string) => {
    if (!text.trim()) return;

    const userMessage: Message = {
      id: messages.length + 1,
      type: 'user',
      text: text,
      time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages([...messages, userMessage]);
    setInputText('');
    setIsTyping(true);

    try {
      const response = await aiService.ask(text);
      
      const assistantMessage: Message = {
        id: messages.length + 2,
        type: 'assistant',
        text: response.answer,
        time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
        confidence: response.confidence
      };
      
      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      console.error('AI Error:', error);
      const errorMessage: Message = {
        id: messages.length + 2,
        type: 'assistant',
        text: '❌ Désolé, une erreur est survenue. Veuillez réessayer.',
        time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
        confidence: 0
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsTyping(false);
    }
  };

  const handleSuggestionClick = (suggestion: string) => {
    handleSendMessage(suggestion);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-gray-900 mb-2">Assistant AI de Prédiction</h1>
        <p className="text-gray-600">Posez vos questions sur les données financières et obtenez des analyses prédictives</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card padding="sm">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <TrendingUp className="w-5 h-5 text-[#0B6FB0]" />
            </div>
            <div>
              <p className="text-xs text-gray-600">Précision</p>
              <p className="text-lg font-bold text-gray-900">94%</p>
            </div>
          </div>
        </Card>
        <Card padding="sm">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <BarChart3 className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="text-xs text-gray-600">Analyses</p>
              <p className="text-lg font-bold text-gray-900">1,247</p>
            </div>
          </div>
        </Card>
        <Card padding="sm">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-orange-100 rounded-lg">
              <AlertCircle className="w-5 h-5 text-orange-600" />
            </div>
            <div>
              <p className="text-xs text-gray-600">Alertes</p>
              <p className="text-lg font-bold text-gray-900">12</p>
            </div>
          </div>
        </Card>
        <Card padding="sm">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-purple-100 rounded-lg">
              <DollarSign className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="text-xs text-gray-600">Économies</p>
              <p className="text-lg font-bold text-gray-900">45K€</p>
            </div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Chat Area */}
        <Card className="lg:col-span-2" padding="none">
          {/* Messages */}
          <div className="h-[500px] overflow-y-auto p-6 space-y-4">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
              >
                <div className={`flex gap-3 max-w-[85%] ${message.type === 'user' ? 'flex-row-reverse' : 'flex-row'}`}>
                  {/* Avatar */}
                  {message.type === 'assistant' && (
                    <div className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                      <Bot className="w-5 h-5 text-white" />
                    </div>
                  )}
                  
                  {/* Message bubble */}
                  <div
                    className={`rounded-2xl px-4 py-3 ${
                      message.type === 'user'
                        ? 'bg-[#0B6FB0] text-white'
                        : 'bg-gray-100 text-gray-900'
                    }`}
                  >
                    <p className="text-sm md:text-base whitespace-pre-line">{message.text}</p>
                    <p
                      className={`text-xs mt-1 ${
                        message.type === 'user' ? 'text-blue-200' : 'text-gray-500'
                      }`}
                    >
                      {message.time}
                    </p>
                  </div>
                </div>
              </div>
            ))}

            {/* Typing indicator */}
            {isTyping && (
              <div className="flex justify-start">
                <div className="flex gap-3 max-w-[85%]">
                  <div className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                    <Bot className="w-5 h-5 text-white" />
                  </div>
                  <div className="bg-gray-100 rounded-2xl px-4 py-3">
                    <div className="flex gap-1">
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Input Area */}
          <div className="border-t border-gray-200 p-4 bg-gray-50">
            <div className="flex gap-3">
              <input
                type="text"
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && inputText && handleSendMessage(inputText)}
                placeholder="Posez votre question sur les finances..."
                className="input flex-1"
                disabled={isTyping}
              />
              <Button
                variant="primary"
                size="md"
                onClick={() => inputText && handleSendMessage(inputText)}
                disabled={!inputText || isTyping}
              >
                <Send className="w-5 h-5" />
              </Button>
            </div>
          </div>
        </Card>

        {/* Suggestions Panel */}
        <div className="space-y-6">
          <Card>
            <h3 className="text-gray-900 mb-4">Questions suggérées</h3>
            <div className="space-y-2">
              {suggestions.map((suggestion, index) => (
                <button
                  key={index}
                  onClick={() => handleSuggestionClick(suggestion)}
                  disabled={isTyping}
                  className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed rounded-lg transition-colors text-sm text-gray-700 border border-gray-200"
                >
                  {suggestion}
                </button>
              ))}
            </div>
          </Card>

          <Card>
            <h3 className="text-gray-900 mb-4">Capacités de l'IA</h3>
            <div className="space-y-3 text-sm text-gray-600">
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <TrendingUp className="w-4 h-4 text-[#0B6FB0]" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Prévisions financières</p>
                  <p className="text-xs mt-1">Analyse prédictive basée sur l'historique</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <AlertCircle className="w-4 h-4 text-orange-600" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Détection d'anomalies</p>
                  <p className="text-xs mt-1">Identification automatique des variations</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <BarChart3 className="w-4 h-4 text-green-600" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Analyse comparative</p>
                  <p className="text-xs mt-1">Comparaison entre services et périodes</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-purple-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <DollarSign className="w-4 h-4 text-purple-600" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Optimisation budgétaire</p>
                  <p className="text-xs mt-1">Recommandations pour réduire les coûts</p>
                </div>
              </div>
            </div>
          </Card>

          <Card className="bg-gradient-to-br from-blue-50 to-purple-50 border border-blue-200">
            <div className="flex items-start gap-3">
              <Bot className="w-6 h-6 text-[#0B6FB0] flex-shrink-0" />
              <div>
                <p className="text-sm font-medium text-gray-900 mb-1">Intelligence Artificielle</p>
                <p className="text-xs text-gray-600">
                  Propulsé par des algorithmes d'apprentissage automatique pour des prédictions précises
                </p>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
