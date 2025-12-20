import React, { useState, useEffect } from 'react';
import { Bed, Plus, Search, Edit, Trash2, Calendar, User, Building2, Clock } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api } from '../services/api';

interface Sejour {
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
  statut: string;
  typeAdmission?: string;
  coutTotal?: number;
}

export function SejoursPage() {
  const [sejours, setSejours] = useState<Sejour[]>([]);
  const [patients, setPatients] = useState<any[]>([]);
  const [services, setServices] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSejour, setEditingSejour] = useState<Sejour | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterStatut, setFilterStatut] = useState<string>('all');
  const [formData, setFormData] = useState({
    patientId: '',
    serviceId: '',
    dateEntree: '',
    dateSortie: '',
    motif: '',
    diagnostic: '',
    statut: 'EN_COURS',
    typeAdmission: 'PROGRAMME',
    coutTotal: ''
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [sejoursData, patientsData, servicesData] = await Promise.all([
        api.getSejours(),
        api.getPatients(),
        api.getServices()
      ]);
      setSejours(sejoursData);
      setPatients(patientsData);
      setServices(servicesData);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des données');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const sejourData: any = {
        patientId: parseInt(formData.patientId),
        serviceId: parseInt(formData.serviceId),
        dateEntree: formData.dateEntree + 'T00:00:00',
        dateSortie: formData.dateSortie ? formData.dateSortie + 'T23:59:59' : undefined,
        motif: formData.motif,
        diagnostic: formData.diagnostic,
        statut: formData.statut,
        typeAdmission: formData.typeAdmission,
        coutTotal: formData.coutTotal ? parseFloat(formData.coutTotal) : undefined
      };

      if (editingSejour) {
        await api.updateSejour(editingSejour.id, sejourData);
      } else {
        await api.createSejour(sejourData);
      }
      
      setIsModalOpen(false);
      setEditingSejour(null);
      resetForm();
      await loadData();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la sauvegarde du séjour');
    }
  };

  const resetForm = () => {
    setFormData({
      patientId: '',
      serviceId: '',
      dateEntree: '',
      dateSortie: '',
      motif: '',
      diagnostic: '',
      statut: 'EN_COURS',
      typeAdmission: 'PROGRAMME',
      coutTotal: ''
    });
  };

  const handleEdit = (sejour: Sejour) => {
    setEditingSejour(sejour);
    setFormData({
      patientId: sejour.patientId.toString(),
      serviceId: sejour.serviceId.toString(),
      dateEntree: sejour.dateEntree.split('T')[0],
      dateSortie: sejour.dateSortie ? sejour.dateSortie.split('T')[0] : '',
      motif: sejour.motif,
      diagnostic: sejour.diagnostic || '',
      statut: sejour.statut,
      typeAdmission: sejour.typeAdmission || 'PROGRAMME',
      coutTotal: sejour.coutTotal?.toString() || ''
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce séjour ?')) {
      try {
        await api.deleteSejour(id);
        await loadData();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression');
      }
    }
  };

  const calculateDuration = (dateEntree: string, dateSortie?: string) => {
    const start = new Date(dateEntree);
    const end = dateSortie ? new Date(dateSortie) : new Date();
    const diffTime = Math.abs(end.getTime() - start.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const getStatutBadge = (statut: string) => {
    switch (statut) {
      case 'EN_COURS': return 'bg-blue-100 text-blue-800';
      case 'TERMINE': return 'bg-green-100 text-green-800';
      case 'ANNULE': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getTypeAdmissionBadge = (type?: string) => {
    switch (type) {
      case 'URGENCE': return 'bg-red-100 text-red-800';
      case 'PROGRAMME': return 'bg-blue-100 text-blue-800';
      case 'TRANSFERT': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const filteredSejours = sejours.filter(s => {
    const matchesSearch = 
      (s.patientNom?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
      (s.patientPrenom?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
      (s.serviceNom?.toLowerCase() || '').includes(searchQuery.toLowerCase());
    
    const matchesStatut = filterStatut === 'all' || s.statut === filterStatut;
    
    return matchesSearch && matchesStatut;
  });

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Séjours</h1>
        <p className="text-gray-600">Gestion des hospitalisations</p>
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
              placeholder="Rechercher par patient ou service..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
            />
          </div>
          
          <select
            value={filterStatut}
            onChange={(e) => setFilterStatut(e.target.value)}
            className="px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white transition-all min-w-[160px]"
          >
            <option value="all">Tous les statuts</option>
            <option value="EN_COURS">✓ En cours</option>
            <option value="TERMINE">✓ Terminé</option>
            <option value="ANNULE">✗ Annulé</option>
          </select>

          <Button 
            onClick={() => {
              setEditingSejour(null);
              resetForm();
              setIsModalOpen(true);
            }}
            className="whitespace-nowrap"
          >
            <Plus className="w-5 h-5 mr-2" />
            Nouveau Séjour
          </Button>
        </div>
        <div className="mt-3 flex items-center gap-2 text-sm text-gray-600">
          <span className="font-medium">{filteredSejours.length}</span>
          <span>séjour(s) trouvé(s)</span>
          {filterStatut !== 'all' && (
            <span className="ml-2 px-2 py-0.5 bg-blue-100 text-blue-700 rounded-full text-xs">
              Filtre: {filterStatut === 'EN_COURS' ? 'En cours' : filterStatut === 'TERMINE' ? 'Terminé' : 'Annulé'}
            </span>
          )}
        </div>
      </Card>

      {/* Sejours Grid */}
      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="text-gray-500">Chargement...</div>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {filteredSejours.map((sejour) => (
            <Card key={sejour.id} className="p-6 hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                    <Bed className="w-6 h-6 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">
                      {sejour.patientPrenom} {sejour.patientNom}
                    </h3>
                    <div className="flex gap-2 mt-1">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getStatutBadge(sejour.statut)}`}>
                        {sejour.statut.replace('_', ' ')}
                      </span>
                      {sejour.typeAdmission && (
                        <span className={`px-2 py-1 rounded text-xs font-medium ${getTypeAdmissionBadge(sejour.typeAdmission)}`}>
                          {sejour.typeAdmission}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                <div className="flex items-center text-gray-600">
                  <Building2 className="w-4 h-4 mr-2" />
                  <span className="font-medium">{sejour.serviceNom}</span>
                </div>

                <div className="flex items-center text-gray-600">
                  <Calendar className="w-4 h-4 mr-2" />
                  <span>
                    Entrée: {new Date(sejour.dateEntree).toLocaleDateString('fr-FR')}
                  </span>
                </div>

                {sejour.dateSortie && (
                  <div className="flex items-center text-gray-600">
                    <Calendar className="w-4 h-4 mr-2" />
                    <span>
                      Sortie: {new Date(sejour.dateSortie).toLocaleDateString('fr-FR')}
                    </span>
                  </div>
                )}

                <div className="flex items-center text-gray-600">
                  <Clock className="w-4 h-4 mr-2" />
                  <span>
                    Durée: {calculateDuration(sejour.dateEntree, sejour.dateSortie)} jour(s)
                  </span>
                </div>

                <div className="pt-2 border-t">
                  <p className="text-sm text-gray-700">
                    <span className="font-medium">Motif:</span> {sejour.motif}
                  </p>
                  {sejour.diagnostic && (
                    <p className="text-sm text-gray-700 mt-1">
                      <span className="font-medium">Diagnostic:</span> {sejour.diagnostic}
                    </p>
                  )}
                </div>

                {sejour.coutTotal !== undefined && sejour.coutTotal !== null && (
                  <div className="pt-2 border-t">
                    <span className="text-lg font-bold text-blue-600">
                      {sejour.coutTotal.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' })}
                    </span>
                  </div>
                )}
              </div>

              <div className="flex gap-2 mt-4">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => handleEdit(sejour)}
                  className="flex-1"
                >
                  <Edit className="w-4 h-4 mr-1" />
                  Modifier
                </Button>
                <Button
                  variant="danger"
                  size="sm"
                  onClick={() => handleDelete(sejour.id)}
                >
                  <Trash2 className="w-4 h-4" />
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {!loading && filteredSejours.length === 0 && (
        <div className="text-center py-12">
          <Bed className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Aucun séjour trouvé</p>
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingSejour(null);
        }}
        title={editingSejour ? 'Modifier le Séjour' : 'Nouveau Séjour'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Patient *
            </label>
            <select
              value={formData.patientId}
              onChange={(e) => setFormData({ ...formData, patientId: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            >
              <option value="">Sélectionner un patient</option>
              {patients.map(p => (
                <option key={p.id} value={p.id}>
                  {p.prenom} {p.nom} - {p.numeroSecuriteSociale}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Service *
            </label>
            <select
              value={formData.serviceId}
              onChange={(e) => setFormData({ ...formData, serviceId: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            >
              <option value="">Sélectionner un service</option>
              {services.map(s => (
                <option key={s.id} value={s.id}>
                  {s.nom}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date d'entrée"
              type="date"
              value={formData.dateEntree}
              onChange={(e) => setFormData({ ...formData, dateEntree: e.target.value })}
              required
            />
            <Input
              label="Date de sortie"
              type="date"
              value={formData.dateSortie}
              min={formData.dateEntree}
              onChange={(e) => setFormData({ ...formData, dateSortie: e.target.value })}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Motif *
            </label>
            <textarea
              value={formData.motif}
              onChange={(e) => setFormData({ ...formData, motif: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={2}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Diagnostic
            </label>
            <textarea
              value={formData.diagnostic}
              onChange={(e) => setFormData({ ...formData, diagnostic: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={2}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Statut *
              </label>
              <select
                value={formData.statut}
                onChange={(e) => setFormData({ ...formData, statut: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="EN_COURS">En cours</option>
                <option value="TERMINE">Terminé</option>
                <option value="ANNULE">Annulé</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Type d'admission
              </label>
              <select
                value={formData.typeAdmission}
                onChange={(e) => setFormData({ ...formData, typeAdmission: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="PROGRAMME">Programmé</option>
                <option value="URGENCE">Urgence</option>
                <option value="TRANSFERT">Transfert</option>
              </select>
            </div>
          </div>

          <Input
            label="Coût total (€)"
            type="number"
            step="0.01"
            value={formData.coutTotal}
            onChange={(e) => setFormData({ ...formData, coutTotal: e.target.value })}
          />

          <div className="flex justify-end gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsModalOpen(false);
                setEditingSejour(null);
              }}
            >
              Annuler
            </Button>
            <Button type="submit">
              {editingSejour ? 'Mettre à jour' : 'Créer'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
