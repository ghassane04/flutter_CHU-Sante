import React, { useState, useEffect } from 'react';
import { UserCog, Plus, Search, Edit, Trash2, Phone, Mail, Building2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api } from '../services/api';

interface Medecin {
  id: number;
  nom: string;
  prenom: string;
  numeroInscription: string;
  specialite: string;
  telephone?: string;
  email?: string;
  serviceId?: number;
  serviceNom?: string;
  statut: string;
}

export function Medecins() {
  const [medecins, setMedecins] = useState<Medecin[]>([]);
  const [services, setServices] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingMedecin, setEditingMedecin] = useState<Medecin | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [formData, setFormData] = useState({
    nom: '',
    prenom: '',
    numeroInscription: '',
    specialite: '',
    telephone: '',
    email: '',
    serviceId: '',
    statut: 'ACTIF'
  });

  useEffect(() => {
    loadMedecins();
    loadServices();
  }, []);

  const loadServices = async () => {
    try {
      const data = await api.getServices();
      setServices(data);
    } catch (err) {
      console.error('Erreur lors du chargement des services:', err);
    }
  };

  const loadMedecins = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getMedecins();
      setMedecins(data);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des médecins');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const medecinData = {
        ...formData,
        serviceId: formData.serviceId ? parseInt(formData.serviceId) : null
      };

      if (editingMedecin) {
        await api.updateMedecin(editingMedecin.id, medecinData);
      } else {
        await api.createMedecin(medecinData);
      }
      
      setIsModalOpen(false);
      setEditingMedecin(null);
      setFormData({
        nom: '',
        prenom: '',
        numeroInscription: '',
        specialite: '',
        telephone: '',
        email: '',
        serviceId: '',
        statut: 'ACTIF'
      });
      await loadMedecins();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la sauvegarde du médecin');
    }
  };

  const handleEdit = (medecin: Medecin) => {
    setEditingMedecin(medecin);
    setFormData({
      nom: medecin.nom,
      prenom: medecin.prenom,
      numeroInscription: medecin.numeroInscription,
      specialite: medecin.specialite,
      telephone: medecin.telephone || '',
      email: medecin.email || '',
      serviceId: medecin.serviceId?.toString() || '',
      statut: medecin.statut
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce médecin ?')) {
      try {
        await api.deleteMedecin(id);
        await loadMedecins();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression');
      }
    }
  };

  const filteredMedecins = medecins.filter(m =>
    m.nom.toLowerCase().includes(searchQuery.toLowerCase()) ||
    m.prenom.toLowerCase().includes(searchQuery.toLowerCase()) ||
    m.specialite.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const getStatutBadge = (statut: string) => {
    switch (statut) {
      case 'ACTIF': return 'bg-green-100 text-green-800';
      case 'CONGE': return 'bg-yellow-100 text-yellow-800';
      case 'INACTIF': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Médecins</h1>
        <p className="text-gray-600">Gestion du personnel médical</p>
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
              placeholder="Rechercher par nom, prénom ou spécialité..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
            />
          </div>
          <Button 
            onClick={() => {
              setEditingMedecin(null);
              setFormData({
                nom: '',
                prenom: '',
                numeroInscription: '',
                specialite: '',
                telephone: '',
                email: '',
                serviceId: '',
                statut: 'ACTIF'
              });
              setIsModalOpen(true);
            }}
            className="whitespace-nowrap"
          >
            <Plus className="w-5 h-5 mr-2" />
            Nouveau Médecin
          </Button>
        </div>
        <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
          <span className="font-medium">{filteredMedecins.length}</span>
          <span>médecin(s) trouvé(s)</span>
        </div>
      </Card>

      {/* Medecins Grid */}
      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="text-gray-500">Chargement...</div>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {filteredMedecins.map((medecin) => (
            <Card key={medecin.id} className="p-6 hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                    <UserCog className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">
                      Dr. {medecin.prenom} {medecin.nom}
                    </h3>
                    <span className={`inline-block px-2 py-1 rounded text-xs font-medium ${getStatutBadge(medecin.statut)}`}>
                      {medecin.statut}
                    </span>
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                <div className="flex items-center text-gray-600">
                  <Building2 className="w-4 h-4 mr-2" />
                  <span className="font-medium">{medecin.specialite}</span>
                </div>
                
                {medecin.serviceNom && (
                  <div className="flex items-center text-gray-600">
                    <Building2 className="w-4 h-4 mr-2" />
                    <span>{medecin.serviceNom}</span>
                  </div>
                )}

                {medecin.telephone && (
                  <div className="flex items-center text-gray-600">
                    <Phone className="w-4 h-4 mr-2" />
                    <span>{medecin.telephone}</span>
                  </div>
                )}

                {medecin.email && (
                  <div className="flex items-center text-gray-600">
                    <Mail className="w-4 h-4 mr-2" />
                    <span className="truncate">{medecin.email}</span>
                  </div>
                )}

                <div className="text-xs text-gray-500 pt-2 border-t">
                  N° Inscription: {medecin.numeroInscription}
                </div>
              </div>

              <div className="flex gap-2 mt-4">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => handleEdit(medecin)}
                  className="flex-1"
                >
                  <Edit className="w-4 h-4 mr-1" />
                  Modifier
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  onClick={() => handleDelete(medecin.id)}
                >
                  <Trash2 className="w-4 h-4" />
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {!loading && filteredMedecins.length === 0 && (
        <div className="text-center py-12">
          <UserCog className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Aucun médecin trouvé</p>
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingMedecin(null);
        }}
        title={editingMedecin ? 'Modifier le Médecin' : 'Nouveau Médecin'}
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
            label="N° Inscription"
            value={formData.numeroInscription}
            onChange={(e) => setFormData({ ...formData, numeroInscription: e.target.value })}
            required
          />

          <Input
            label="Spécialité"
            value={formData.specialite}
            onChange={(e) => setFormData({ ...formData, specialite: e.target.value })}
            placeholder="Ex: Cardiologie, Chirurgie..."
            required
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

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Service
              </label>
              <select
                value={formData.serviceId}
                onChange={(e) => setFormData({ ...formData, serviceId: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Aucun service</option>
                {services.map((service) => (
                  <option key={service.id} value={service.id}>
                    {service.nom}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Statut
              </label>
              <select
                value={formData.statut}
                onChange={(e) => setFormData({ ...formData, statut: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="ACTIF">Actif</option>
                <option value="CONGE">En congé</option>
                <option value="INACTIF">Inactif</option>
              </select>
            </div>
          </div>

          <div className="flex justify-end gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsModalOpen(false);
                setEditingMedecin(null);
              }}
            >
              Annuler
            </Button>
            <Button type="submit">
              {editingMedecin ? 'Mettre à jour' : 'Créer'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
