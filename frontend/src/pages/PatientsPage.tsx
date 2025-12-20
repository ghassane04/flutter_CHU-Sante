import React, { useState, useEffect } from 'react';
import { Users, Plus, Search, Edit, Trash2, Phone, Mail, Calendar, User } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api } from '../services/api';

interface Patient {
  id: number;
  nom: string;
  prenom: string;
  numeroSecuriteSociale: string;
  dateNaissance: string;
  sexe?: string;
  adresse?: string;
  telephone?: string;
  email?: string;
}

export function PatientsPage() {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingPatient, setEditingPatient] = useState<Patient | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [formData, setFormData] = useState({
    nom: '',
    prenom: '',
    numeroSecuriteSociale: '',
    dateNaissance: '',
    sexe: 'M',
    adresse: '',
    telephone: '',
    email: ''
  });

  useEffect(() => {
    loadPatients();
  }, []);

  const loadPatients = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getPatients();
      setPatients(data);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des patients');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingPatient) {
        await api.updatePatient(editingPatient.id, formData);
      } else {
        await api.createPatient(formData);
      }
      
      setIsModalOpen(false);
      setEditingPatient(null);
      setFormData({
        nom: '',
        prenom: '',
        numeroSecuriteSociale: '',
        dateNaissance: '',
        sexe: 'M',
        adresse: '',
        telephone: '',
        email: ''
      });
      await loadPatients();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la sauvegarde du patient');
    }
  };

  const handleEdit = (patient: Patient) => {
    setEditingPatient(patient);
    setFormData({
      nom: patient.nom,
      prenom: patient.prenom,
      numeroSecuriteSociale: patient.numeroSecuriteSociale,
      dateNaissance: patient.dateNaissance,
      sexe: patient.sexe || 'M',
      adresse: patient.adresse || '',
      telephone: patient.telephone || '',
      email: patient.email || ''
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce patient ?')) {
      try {
        await api.deletePatient(id);
        await loadPatients();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression');
      }
    }
  };

  const filteredPatients = patients.filter(p =>
    p.nom.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.prenom.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.numeroSecuriteSociale.includes(searchQuery)
  );

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Patients</h1>
        <p className="text-gray-600">Gestion des dossiers patients</p>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {/* Actions Bar */}
      <Card className="p-4 mb-6">
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Rechercher par nom, prénom ou N° Sécurité Sociale..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
            />
          </div>
          <Button 
            onClick={() => {
              setEditingPatient(null);
              setFormData({
                nom: '',
                prenom: '',
                numeroSecuriteSociale: '',
                dateNaissance: '',
                sexe: 'M',
                adresse: '',
                telephone: '',
                email: ''
              });
              setIsModalOpen(true);
            }}
            className="whitespace-nowrap"
          >
            <Plus className="w-5 h-5 mr-2" />
            Nouveau Patient
          </Button>
        </div>
        <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
          <span className="font-medium">{filteredPatients.length}</span>
          <span>patient(s) trouvé(s)</span>
        </div>
      </Card>

      {/* Patients Grid */}
      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="text-gray-500">Chargement...</div>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {filteredPatients.map((patient) => (
            <Card key={patient.id} className="p-6 hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className={`w-12 h-12 ${patient.sexe === 'F' ? 'bg-pink-100' : 'bg-blue-100'} rounded-full flex items-center justify-center`}>
                    <Users className={`w-6 h-6 ${patient.sexe === 'F' ? 'text-pink-600' : 'text-blue-600'}`} />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">
                      {patient.prenom} {patient.nom}
                    </h3>
                    <span className="text-xs text-gray-500">
                      {patient.sexe === 'F' ? 'Femme' : 'Homme'}
                    </span>
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                <div className="flex items-center text-gray-600">
                  <User className="w-4 h-4 mr-2" />
                  <span>NSS: {patient.numeroSecuriteSociale}</span>
                </div>

                <div className="flex items-center text-gray-600">
                  <Calendar className="w-4 h-4 mr-2" />
                  <span>
                    {new Date(patient.dateNaissance).toLocaleDateString('fr-FR')}
                    {patient.age !== undefined && patient.age !== null && ` (${patient.age} ans)`}
                  </span>
                </div>

                {patient.telephone && (
                  <div className="flex items-center text-gray-600">
                    <Phone className="w-4 h-4 mr-2" />
                    <span>{patient.telephone}</span>
                  </div>
                )}

                {patient.email && (
                  <div className="flex items-center text-gray-600">
                    <Mail className="w-4 h-4 mr-2" />
                    <span className="truncate">{patient.email}</span>
                  </div>
                )}
              </div>

              <div className="flex gap-2 mt-4">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => handleEdit(patient)}
                  className="flex-1"
                >
                  <Edit className="w-4 h-4 mr-1" />
                  Modifier
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  onClick={() => handleDelete(patient.id)}
                >
                  <Trash2 className="w-4 h-4" />
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {!loading && filteredPatients.length === 0 && (
        <div className="text-center py-12">
          <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Aucun patient trouvé</p>
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingPatient(null);
        }}
        title={editingPatient ? 'Modifier le Patient' : 'Nouveau Patient'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nom"
              value={formData.nom}
              onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
              required
            />
            <Input
              label="Prénom"
              value={formData.prenom}
              onChange={(e) => setFormData({ ...formData, prenom: e.target.value })}
              required
            />
          </div>

          <Input
            label="N° Sécurité Sociale"
            value={formData.numeroSecuriteSociale}
            onChange={(e) => setFormData({ ...formData, numeroSecuriteSociale: e.target.value })}
            placeholder="Ex: 1 85 03 75 120 123 45"
            required
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date de Naissance"
              type="date"
              value={formData.dateNaissance}
              onChange={(e) => setFormData({ ...formData, dateNaissance: e.target.value })}
              required
            />
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Sexe
              </label>
              <select
                value={formData.sexe}
                onChange={(e) => setFormData({ ...formData, sexe: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="M">Homme</option>
                <option value="F">Femme</option>
              </select>
            </div>
          </div>

          <Input
            label="Adresse"
            value={formData.adresse}
            onChange={(e) => setFormData({ ...formData, adresse: e.target.value })}
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Téléphone"
              type="tel"
              value={formData.telephone}
              onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
            />
            <Input
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            />
          </div>

          <div className="flex justify-end gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsModalOpen(false);
                setEditingPatient(null);
              }}
            >
              Annuler
            </Button>
            <Button type="submit">
              {editingPatient ? 'Mettre à jour' : 'Créer'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
