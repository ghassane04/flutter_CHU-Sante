// API Service pour communiquer avec le backend
const API_URL = 'http://localhost:8085/api';

// Helper pour ajouter le token JWT
const getAuthHeaders = (): HeadersInit => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` })
  };
};

// Interfaces Auth
export interface LoginRequest {
  username: string;
  password: string;
}

export interface SignupRequest {
  username: string;
  password: string;
  email: string;
  nom: string;
  prenom: string;
}

export interface JwtResponse {
  token: string;
  id: number;
  username: string;
  email: string;
}

export interface MessageResponse {
  message: string;
}

// Interfaces
export interface Patient {
  id: number;
  nom: string;
  prenom: string;
  numeroSecuriteSociale: string;
  dateNaissance: string;
  sexe: string;
  adresse?: string;
  telephone?: string;
  email?: string;
  age?: number; // Calculé automatiquement par le backend
}

export interface Service {
  id: number;
  nom: string;
  description?: string;
  type: string;
  capacite?: number;
  litsDisponibles?: number;
  responsable?: string;
}

export interface Sejour {
  id: number;
  patientId: number;
  patientNom?: string;
  patientPrenom?: string;
  serviceId: number;
  serviceNom?: string;
  dateEntree: string;
  dateSortie?: string;
  motif: string;
  diagnostic?: string;
  statut: 'EN_COURS' | 'TERMINE' | 'ANNULE';
  typeAdmission?: string;
  coutTotal?: number;
}

export interface ActeMedical {
  id: number;
  sejourId: number;
  code: string;
  libelle: string;
  type: string;
  dateRealisation: string;
  tarif: number;
  medecin?: string;
  notes?: string;
}

export interface DashboardStats {
  totalPatients: number;
  sejoursEnCours: number;
  totalActes: number;
  revenusTotal: number;
  revenusAnnee: number;
  revenusMois: number;
}

export interface ActesByTypeStats {
  type: string;
  count: number;
  revenus: number;
}

export interface RevenusByMonthStats {
  mois: string;
  revenus: number;
  actes: number;
}

export interface SejoursByServiceStats {
  service: string;
  actifs: number;
  total: number;
}

export interface Investment {
  id: number;
  nom: string;
  categorie: string;
  description?: string;
  montant: number;
  dateInvestissement: string;
  dateFinPrevue?: string;
  statut: 'PLANIFIE' | 'EN_COURS' | 'TERMINE' | 'ANNULE';
  fournisseur?: string;
  responsable?: string;
  beneficesAttendus?: string;
  retourInvestissement?: number;
}

export interface Alert {
  id: number;
  titre: string;
  message: string;
  type: 'SUCCESS' | 'INFO' | 'WARNING' | 'ERROR';
  priorite: 'BASSE' | 'MOYENNE' | 'HAUTE' | 'CRITIQUE';
  categorie: string;
  lu: boolean;
  resolu: boolean;
  assigneeA?: string;
  dateResolution?: string;
  commentaire?: string;
  createdAt: string;
}

export interface Report {
  id: number;
  titre: string;
  type: string;
  periode: string;
  resume?: string;
  dateDebut: string;
  dateFin: string;
  generePar?: string;
  donneesPrincipales?: any;
  conclusions?: string;
  recommandations?: string;
  statut: 'BROUILLON' | 'PUBLIE' | 'ARCHIVE';
  createdAt: string;
}

export interface Prediction {
  id: number;
  type: string;
  titre: string;
  description?: string;
  periodePrevue: string;
  donneesHistoriques?: any;
  resultatPrediction?: any;
  confiance?: number;
  methodologie?: string;
  facteursCles?: string;
  recommandations?: string;
  generePar?: string;
  createdAt: string;
}

export interface User {
  id: number;
  username: string;
  email: string;
  nom?: string;
  prenom?: string;
  enabled: boolean;
  roles?: Role[];
  createdAt: string;
}

export interface Role {
  id: number;
  name: string;
  description?: string;
}

export interface UserCreateRequest {
  username: string;
  password: string;
  email: string;
  nom?: string;
  prenom?: string;
  actif?: boolean;
  roleIds?: number[];
}

export interface Setting {
  id: number;
  cle: string;
  valeur: string;
  type: string;
  description?: string;
  createdAt?: string;
  updatedAt?: string;
}

// API Functions
export const api = {
  // Auth
  async login(credentials: LoginRequest): Promise<JwtResponse> {
    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      });
      if (!response.ok) {
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
          const error = await response.json();
          throw new Error(error.message || 'Erreur lors de la connexion');
        } else {
          throw new Error(`Erreur HTTP ${response.status}: ${response.statusText}`);
        }
      }
      const data = await response.json();
      // Stocker le token
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify({ id: data.id, username: data.username, email: data.email }));
      return data;
    } catch (error: any) {
      if (error.message) throw error;
      throw new Error('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
    }
  },

  async signup(signupData: SignupRequest): Promise<MessageResponse> {
    try {
      const response = await fetch(`${API_URL}/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(signupData),
      });
      if (!response.ok) {
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
          const error = await response.json();
          throw new Error(error.message || 'Erreur lors de l\'inscription');
        } else {
          throw new Error(`Erreur HTTP ${response.status}: ${response.statusText}`);
        }
      }
      return response.json();
    } catch (error: any) {
      if (error.message) throw error;
      throw new Error('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
    }
  },

  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  isAuthenticated(): boolean {
    return !!localStorage.getItem('token');
  },

  getCurrentUser(): { id: number; username: string; email: string } | null {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  },

  async checkUsername(username: string): Promise<boolean> {
    const response = await fetch(`${API_URL}/auth/check-username/${username}`);
    const data = await response.json();
    return data.message === 'exists';
  },

  async checkEmail(email: string): Promise<boolean> {
    const response = await fetch(`${API_URL}/auth/check-email/${email}`);
    const data = await response.json();
    return data.message === 'exists';
  },

  // Dashboard
  async getDashboardStats(): Promise<DashboardStats> {
    const response = await fetch(`${API_URL}/dashboard/stats`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des statistiques');
    return response.json();
  },

  async getActesByType(): Promise<ActesByTypeStats[]> {
    const response = await fetch(`${API_URL}/dashboard/actes-by-type`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des actes par type');
    return response.json();
  },

  async getRevenusByMonth(): Promise<RevenusByMonthStats[]> {
    const response = await fetch(`${API_URL}/dashboard/revenus-by-month`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des revenus par mois');
    return response.json();
  },

  async getSejoursByService(): Promise<SejoursByServiceStats[]> {
    const response = await fetch(`${API_URL}/dashboard/sejours-by-service`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des séjours par service');
    return response.json();
  },

  // Patients
  async getPatients(): Promise<Patient[]> {
    const response = await fetch(`${API_URL}/patients`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des patients');
    return response.json();
  },

  async getPatient(id: number): Promise<Patient> {
    const response = await fetch(`${API_URL}/patients/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du patient');
    return response.json();
  },

  async createPatient(patient: Omit<Patient, 'id'>): Promise<Patient> {
    const response = await fetch(`${API_URL}/patients`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(patient),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du patient');
    return response.json();
  },

  async updatePatient(id: number, patient: Partial<Patient>): Promise<Patient> {
    const response = await fetch(`${API_URL}/patients/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(patient),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du patient');
    return response.json();
  },

  async deletePatient(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/patients/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du patient');
  },

  // Services
  async getServices(): Promise<Service[]> {
    const response = await fetch(`${API_URL}/services`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des services');
    return response.json();
  },

  async getService(id: number): Promise<Service> {
    const response = await fetch(`${API_URL}/services/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du service');
    return response.json();
  },

  async createService(service: Omit<Service, 'id'>): Promise<Service> {
    const response = await fetch(`${API_URL}/services`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(service),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du service');
    return response.json();
  },

  async updateService(id: number, service: Partial<Service>): Promise<Service> {
    const response = await fetch(`${API_URL}/services/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(service),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du service');
    return response.json();
  },

  async deleteService(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/services/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du service');
  },

  // Séjours
  async getSejours(): Promise<Sejour[]> {
    const response = await fetch(`${API_URL}/sejours`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des séjours');
    return response.json();
  },

  async getSejour(id: number): Promise<Sejour> {
    const response = await fetch(`${API_URL}/sejours/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du séjour');
    return response.json();
  },

  async getSejoursEnCours(): Promise<Sejour[]> {
    const response = await fetch(`${API_URL}/sejours/en-cours`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des séjours en cours');
    return response.json();
  },

  async createSejour(sejour: Omit<Sejour, 'id'>): Promise<Sejour> {
    const response = await fetch(`${API_URL}/sejours`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(sejour),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du séjour');
    return response.json();
  },

  async updateSejour(id: number, sejour: Partial<Sejour>): Promise<Sejour> {
    const response = await fetch(`${API_URL}/sejours/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(sejour),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du séjour');
    return response.json();
  },

  async deleteSejour(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/sejours/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du séjour');
  },

  // Actes médicaux
  async getActes(): Promise<ActeMedical[]> {
    const response = await fetch(`${API_URL}/actes`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des actes');
    return response.json();
  },

  async getActe(id: number): Promise<ActeMedical> {
    const response = await fetch(`${API_URL}/actes/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de l\'acte');
    return response.json();
  },

  async getActesBySejourId(sejourId: number): Promise<ActeMedical[]> {
    const response = await fetch(`${API_URL}/actes/sejour/${sejourId}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des actes du séjour');
    return response.json();
  },

  async createActe(acte: Omit<ActeMedical, 'id'>): Promise<ActeMedical> {
    const response = await fetch(`${API_URL}/actes`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(acte),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de l\'acte');
    return response.json();
  },

  async updateActe(id: number, acte: Partial<ActeMedical>): Promise<ActeMedical> {
    const response = await fetch(`${API_URL}/actes/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(acte),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de l\'acte');
    return response.json();
  },

  async deleteActe(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/actes/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'acte');
  },

  // Investissements
  async getInvestments(): Promise<Investment[]> {
    const response = await fetch(`${API_URL}/investments`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des investissements');
    return response.json();
  },

  async getInvestment(id: number): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de l\'investissement');
    return response.json();
  },

  async createInvestment(investment: Omit<Investment, 'id'>): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(investment),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de l\'investissement');
    return response.json();
  },

  async updateInvestment(id: number, investment: Partial<Investment>): Promise<Investment> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(investment),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de l\'investissement');
    return response.json();
  },

  async deleteInvestment(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/investments/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'investissement');
  },

  // Alertes
  async getAlerts(): Promise<Alert[]> {
    const response = await fetch(`${API_URL}/alerts`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des alertes');
    return response.json();
  },

  async getAlert(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de l\'alerte');
    return response.json();
  },

  async createAlert(alert: Omit<Alert, 'id' | 'createdAt'>): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(alert),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de l\'alerte');
    return response.json();
  },

  async updateAlert(id: number, alert: Partial<Alert>): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(alert),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de l\'alerte');
    return response.json();
  },

  async markAlertAsRead(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}/lire`, {
      method: 'PUT',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors du marquage de l\'alerte comme lue');
    return response.json();
  },

  async markAlertAsResolved(id: number): Promise<Alert> {
    const response = await fetch(`${API_URL}/alerts/${id}/resoudre`, {
      method: 'PUT',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors du marquage de l\'alerte comme résolue');
    return response.json();
  },

  async deleteAlert(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/alerts/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'alerte');
  },

  // Rapports
  async getReports(): Promise<Report[]> {
    const response = await fetch(`${API_URL}/reports`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des rapports');
    return response.json();
  },

  async getReport(id: number): Promise<Report> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du rapport');
    return response.json();
  },

  async createReport(report: Omit<Report, 'id' | 'createdAt'>): Promise<Report> {
    const response = await fetch(`${API_URL}/reports`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(report),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du rapport');
    return response.json();
  },

  async updateReport(id: number, report: Partial<Report>): Promise<Report> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(report),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du rapport');
    return response.json();
  },

  async deleteReport(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/reports/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du rapport');
  },

  // Prédictions
  async getPredictions(): Promise<Prediction[]> {
    const response = await fetch(`${API_URL}/predictions`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des prédictions');
    return response.json();
  },

  async getPrediction(id: number): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de la prédiction');
    return response.json();
  },

  async createPrediction(prediction: Omit<Prediction, 'id' | 'createdAt'>): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(prediction),
    });
    if (!response.ok) throw new Error('Erreur lors de la création de la prédiction');
    return response.json();
  },

  async updatePrediction(id: number, prediction: Partial<Prediction>): Promise<Prediction> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(prediction),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour de la prédiction');
    return response.json();
  },

  async deletePrediction(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/predictions/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de la prédiction');
  },

  // Utilisateurs (nécessite authentification ADMIN)
  async getUsers(): Promise<User[]> {
    const response = await fetch(`${API_URL}/users`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des utilisateurs');
    return response.json();
  },

  async getUser(id: number): Promise<User> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de l\'utilisateur');
    return response.json();
  },

  async createUser(user: UserCreateRequest): Promise<User> {
    const response = await fetch(`${API_URL}/users`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la création de l\'utilisateur');
    }
    return response.json();
  },

  async updateUser(id: number, user: Partial<UserCreateRequest>): Promise<User> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la mise à jour de l\'utilisateur');
    }
    return response.json();
  },

  async deleteUser(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'utilisateur');
  },

  async toggleUserStatus(id: number): Promise<User> {
    const response = await fetch(`${API_URL}/users/${id}/toggle-status`, {
      method: 'PUT',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors du changement de statut');
    return response.json();
  },

  async getRoles(): Promise<Role[]> {
    const response = await fetch(`${API_URL}/users/roles`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des rôles');
    return response.json();
  },

  // ==================== MEDECINS ====================
  async getMedecins(): Promise<any[]> {
    const response = await fetch(`${API_URL}/medecins`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des médecins');
    return response.json();
  },

  async getMedecin(id: number): Promise<any> {
    const response = await fetch(`${API_URL}/medecins/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du médecin');
    return response.json();
  },

  async createMedecin(medecin: any): Promise<any> {
    const response = await fetch(`${API_URL}/medecins`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(medecin),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la création du médecin');
    }
    return response.json();
  },

  async updateMedecin(id: number, medecin: any): Promise<any> {
    const response = await fetch(`${API_URL}/medecins/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(medecin),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la mise à jour du médecin');
    }
    return response.json();
  },

  async deleteMedecin(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/medecins/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du médecin');
  },

  // Settings (Paramètres)
  async getSettings(): Promise<Setting[]> {
    const response = await fetch(`${API_URL}/settings`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des paramètres');
    return response.json();
  },

  async getSetting(id: number): Promise<Setting> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du paramètre');
    return response.json();
  },

  async getSettingByKey(key: string): Promise<Setting> {
    const response = await fetch(`${API_URL}/settings/key/${key}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération du paramètre');
    return response.json();
  },

  async createSetting(setting: Omit<Setting, 'id'>): Promise<Setting> {
    const response = await fetch(`${API_URL}/settings`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(setting),
    });
    if (!response.ok) throw new Error('Erreur lors de la création du paramètre');
    return response.json();
  },

  async updateSetting(id: number, setting: Partial<Setting>): Promise<Setting> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(setting),
    });
    if (!response.ok) throw new Error('Erreur lors de la mise à jour du paramètre');
    return response.json();
  },

  async deleteSetting(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/settings/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression du paramètre');
  },

  // Users Management
  async getUsers(): Promise<User[]> {
    const response = await fetch(`${API_URL}/users`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération des utilisateurs');
    return response.json();
  },

  async getUser(id: number): Promise<User> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la récupération de l\'utilisateur');
    return response.json();
  },

  async createUser(user: UserCreateRequest): Promise<User> {
    const response = await fetch(`${API_URL}/users`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la création de l\'utilisateur');
    }
    return response.json();
  },

  async updateUser(id: number, user: Partial<Omit<User, 'id' | 'createdAt' | 'roles'>>): Promise<User> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
    });
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Erreur lors de la mise à jour de l\'utilisateur');
    }
    return response.json();
  },

  async deleteUser(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Erreur lors de la suppression de l\'utilisateur');
  },
};
