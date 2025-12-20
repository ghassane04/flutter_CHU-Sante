const API_URL = 'http://localhost:8085/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export interface Report {
  id?: number;
  titre: string;
  type: string;
  periode: string;
  resume?: string;
  dateDebut: string;
  dateFin: string;
  generePar?: string;
  donneesPrincipales?: string;
  conclusions?: string;
  recommandations?: string;
  statut: string;
  createdAt?: string;
  updatedAt?: string;
}

export const reportService = {
  async getAll(): Promise<Report[]> {
    const response = await fetch(`${API_URL}/reports`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des rapports');
    return response.json();
  },

  async getById(id: number): Promise<Report> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Rapport non trouvé');
    return response.json();
  },

  async getByType(type: string): Promise<Report[]> {
    const response = await fetch(`${API_URL}/reports/type/${type}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des rapports');
    return response.json();
  },

  async getByPeriode(periode: string): Promise<Report[]> {
    const response = await fetch(`${API_URL}/reports/periode/${periode}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des rapports');
    return response.json();
  },

  async create(report: Report): Promise<Report> {
    const response = await fetch(`${API_URL}/reports`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(report),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du rapport');
    return response.json();
  },

  async update(id: number, report: Report): Promise<Report> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(report),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du rapport');
    return response.json();
  },

  async delete(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du rapport');
  },
};
