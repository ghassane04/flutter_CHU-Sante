const API_URL = 'http://localhost:8085/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export interface Settings {
  id?: number;
  cle: string;
  categorie: string;
  libelle: string;
  valeur: string;
  typeValeur: string;
  description?: string;
  valeurParDefaut?: string;
  createdAt?: string;
  updatedAt?: string;
}

export const settingsService = {
  async getAll(): Promise<Settings[]> {
    const response = await fetch(`${API_URL}/settings`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des paramètres');
    return response.json();
  },

  async getById(id: number): Promise<Settings> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Paramètre non trouvé');
    return response.json();
  },

  async getByCle(cle: string): Promise<Settings> {
    const response = await fetch(`${API_URL}/settings/cle/${cle}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Paramètre non trouvé');
    return response.json();
  },

  async getByCategorie(categorie: string): Promise<Settings[]> {
    const response = await fetch(`${API_URL}/settings/categorie/${categorie}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des paramètres');
    return response.json();
  },

  async create(settings: Settings): Promise<Settings> {
    const response = await fetch(`${API_URL}/settings`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(settings),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du paramètre');
    return response.json();
  },

  async update(id: number, settings: Settings): Promise<Settings> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(settings),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du paramètre');
    return response.json();
  },

  async delete(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du paramètre');
  },
};
