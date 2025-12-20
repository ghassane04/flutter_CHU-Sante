const API_URL = 'http://localhost:8085/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export interface Investment {
  id?: number;
  nom: string;
  categorie: string;
  description: string;
  montant: number;
  dateInvestissement: string;
  dateFinPrevue?: string;
  statut: string;
  fournisseur?: string;
  responsable?: string;
  beneficesAttendus?: string;
  retourInvestissement?: number;
  createdAt?: string;
  updatedAt?: string;
}

export const investmentService = {
  async getAll(): Promise<Investment[]> {
    const response = await fetch(`${API_URL}/investments`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des investissements');
    return response.json();
  },

  async getById(id: number): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Investissement non trouvé');
    return response.json();
  },

  async getStats(): Promise<any> {
    const response = await fetch(`${API_URL}/investments/stats`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des statistiques');
    return response.json();
  },

  async create(investment: Investment): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(investment),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de l\'investissement');
    return response.json();
  },

  async update(id: number, investment: Investment): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(investment),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de l\'investissement');
    return response.json();
  },

  async delete(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'investissement');
  },
};
