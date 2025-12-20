// Service pour l'intégration AI avec Google Gemini via backend
const API_URL = 'http://localhost:8085/api';

interface AIResponse {
  answer: string;
  confidence: number;
  sources?: string[];
}

// Helper pour ajouter le token JWT
const getAuthHeaders = (): HeadersInit => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` })
  };
};

class AIService {
  async ask(question: string): Promise<AIResponse> {
    try {
      const response = await fetch(`${API_URL}/ai/ask`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ question })
      });

      if (!response.ok) {
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
          const error = await response.json();
          throw new Error(error.message || 'Erreur lors de la requête AI');
        } else {
          throw new Error(`Erreur HTTP ${response.status}: ${response.statusText}`);
        }
      }

      const data = await response.json();
      return {
        answer: data.answer,
        confidence: data.confidence || 0.9,
        sources: data.sources || ['Google Gemini AI', 'Base de données MySQL']
      };
    } catch (error: any) {
      console.error('AI API Error:', error);
      return this.fallbackResponse(question, error.message);
    }
  }

  private fallbackResponse(question: string, errorMessage?: string): AIResponse {
    const lowerQuestion = question.toLowerCase();

    if (errorMessage) {
      return {
        answer: `❌ **Erreur de connexion à l'IA**\n\nDétails: ${errorMessage}\n\n💡 Vérifiez que:\n- Le backend est démarré (http://localhost:8085)\n- Vous êtes connecté\n- La clé API Google Gemini est configurée`,
        confidence: 0.0,
        sources: ['Système local']
      };
    }

    // Analyser les types de questions
    if (lowerQuestion.includes('patient')) {
      return {
        answer: 'Pour obtenir des statistiques patients avec l\'IA, connectez-vous et le système utilisera Google Gemini pour analyser les données MySQL en temps réel.',
        confidence: 0.7,
        sources: ['Base de données MySQL']
      };
    }

    if (lowerQuestion.includes('revenu') || lowerQuestion.includes('coût')) {
      return {
        answer: 'L\'analyse des revenus est maintenant disponible via Google Gemini AI. Le système analyse automatiquement les données de la base de données MySQL.',
        confidence: 0.7,
        sources: ['Système de données local']
      };
    }

    return {
      answer: `🤖 **Assistant IA avec Google Gemini**\n\nL'assistant est maintenant connecté à:\n✅ Google Gemini AI (gemini-pro)\n✅ Base de données MySQL (healthcare_dashboard)\n✅ Authentification JWT\n\nPosez vos questions sur les patients, services, séjours, revenus, etc.`,
      confidence: 0.8,
      sources: ['Configuration système']
    };
  }
}

export const aiService = new AIService();
