const API_URL = 'http://localhost:8085/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export interface Alert {
  id?: number;
  titre: string;
  message: string;
  type: string;
  priorite: string;
  categorie: string;
  lu: boolean;
  resolu: boolean;
  assigneA?: string;
  dateResolution?: string;
  commentaire?: string;
  createdAt?: string;
  updatedAt?: string;
}

export const alertService = {
  async getAll(): Promise<Alert[]> {
    const response = await fetch(`${API_URL}/alerts`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des alertes');
    return response.json();
  },

  async getById(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Alerte non trouvée');
    return response.json();
  },

  async getUnread(): Promise<Alert[]> {
    const response = await fetch(`${API_URL}/alerts/non-lues`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des alertes non lues');
    return response.json();
  },

  async getUnresolved(): Promise<Alert[]> {
    const response = await fetch(`${API_URL}/alerts/non-resolues`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des alertes non résolues');
    return response.json();
  },

  async getStats(): Promise<any> {
    const response = await fetch(`${API_URL}/alerts/stats`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des statistiques');
    return response.json();
  },

  async markAsRead(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}/lire`, {
      method: 'PUT',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors du marquage comme lu');
    return response.json();
  },

  async markAsResolved(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}/resoudre`, {
      method: 'PUT',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors du marquage comme résolu');
    return response.json();
  },

  async create(alert: Alert): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(alert),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de l\'alerte');
    return response.json();
  },

  async update(id: number, alert: Alert): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(alert),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de l\'alerte');
    return response.json();
  },

  async delete(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'alerte');
  },
};
