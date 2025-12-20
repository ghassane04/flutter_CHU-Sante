const API_URL = 'http://localhost:8085/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export interface Prediction {
  id?: number;
  type: string;
  titre: string;
  description?: string;
  periodePrevue: string;
  donneesHistoriques?: string;
  resultatPrediction?: string;
  confiance?: number;
  methodologie?: string;
  facteursCles?: string;
  recommandations?: string;
  generePar?: string;
  createdAt?: string;
  updatedAt?: string;
}

export const predictionService = {
  async getAll(): Promise<Prediction[]> {
    const response = await fetch(`${API_URL}/predictions`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des prédictions');
    return response.json();
  },

  async getById(id: number): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Prédiction non trouvée');
    return response.json();
  },

  async getByType(type: string): Promise<Prediction[]> {
    const response = await fetch(`${API_URL}/predictions/type/${type}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des prédictions');
    return response.json();
  },

  async generate(type: string, titre: string, periodePrevue: string): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions/generate`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({ type, titre, periodePrevue }),
    });
    if (!response.ok) throw new Error('Erreur lors de la génération de la prédiction');
    return response.json();
  },

  async create(prediction: Prediction): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(prediction),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de la prédiction');
    return response.json();
  },

  async update(id: number, prediction: Prediction): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(prediction),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de la prédiction');
    return response.json();
  },

  async delete(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de la prédiction');
  },
};
