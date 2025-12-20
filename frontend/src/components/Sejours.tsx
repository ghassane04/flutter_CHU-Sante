import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search } from 'lucide-react';
import { api, Sejour, Patient, Service } from '../services/api';
import { Button } from './ui/Button';
import { Card } from './ui/Card';

export function Sejours() {
  const [sejours, setSejours] = useState<Sejour[]>([]);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [services, setServices] = useState<Service[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSejour, setEditingSejour] = useState<Sejour | null>(null);
  const [formData, setFormData] = useState({
    patientId: 0,
    serviceId: 0,
    dateEntree: '',
    dateSortie: '',
    motif: '',
    diagnostic: ''
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [sejoursData, patientsData, servicesData] = await Promise.all([
        api.getSejours(),
        api.getPatients(),
        api.getServices()
      ]);
      setSejours(sejoursData);
      setPatients(patientsData);
      setServices(servicesData);
      setError(null);
    } catch (err) {
      setError('Erreur lors du chargement des données');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingSejour) {
        await api.updateSejour(editingSejour.id, formData);
      } else {
        await api.createSejour(formData);
      }
      await loadData();
      closeModal();
    } catch (err) {
      alert('Erreur lors de l\'enregistrement du séjour');
      console.error(err);
    }
  };

  const handleDelete = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce séjour ?')) {
      try {
        await api.deleteSejour(id);
        await loadData();
      } catch (err) {
        alert('Erreur lors de la suppression du séjour');
        console.error(err);
      }
    }
  };

  const openModal = (sejour?: Sejour) => {
    if (sejour) {
      setEditingSejour(sejour);
      setFormData({
        patientId: sejour.patient.id,
        serviceId: sejour.service.id,
        dateEntree: sejour.dateEntree,
        dateSortie: sejour.dateSortie || '',
        motif: sejour.motif || '',
        diagnostic: sejour.diagnostic || ''
      });
    } else {
      setEditingSejour(null);
      setFormData({
        patientId: patients[0]?.id || 0,
        serviceId: services[0]?.id || 0,
        dateEntree: new Date().toISOString().split('T')[0],
        dateSortie: '',
        motif: '',
        diagnostic: ''
      });
    }
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingSejour(null);
  };

  const filteredSejours = sejours.filter(sejour =>
    sejour.patient.nom.toLowerCase().includes(searchTerm.toLowerCase()) ||
    sejour.patient.prenom.toLowerCase().includes(searchTerm.toLowerCase()) ||
    sejour.service.nom.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return <div className="flex items-center justify-center h-64">Chargement...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Gestion des Séjours</h1>
        <Button variant="primary" size="md" onClick={() => openModal()}>
          <Plus className="w-4 h-4 mr-2" />
          Nouveau Séjour
        </Button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <Card>
        <div className="mb-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Rechercher un séjour..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Patient
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Service
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date Entrée
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date Sortie
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Statut
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredSejours.map((sejour) => (
                <tr key={sejour.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {sejour.patient.nom} {sejour.patient.prenom}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {sejour.service.nom}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(sejour.dateEntree).toLocaleDateString('fr-FR')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {sejour.dateSortie ? new Date(sejour.dateSortie).toLocaleDateString('fr-FR') : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      sejour.dateSortie 
                        ? 'bg-gray-100 text-gray-800' 
                        : 'bg-green-100 text-green-800'
                    }`}>
                      {sejour.dateSortie ? 'Terminé' : 'En cours'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => openModal(sejour)}
                      className="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(sejour.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
            <h2 className="text-xl font-bold mb-4">
              {editingSejour ? 'Modifier le Séjour' : 'Nouveau Séjour'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Patient</label>
                  <select
                    required
                    value={formData.patientId}
                    onChange={(e) => setFormData({ ...formData, patientId: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  >
                    <option value="">Sélectionner un patient</option>
                    {patients.map(patient => (
                      <option key={patient.id} value={patient.id}>
                        {patient.nom} {patient.prenom}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Service</label>
                  <select
                    required
                    value={formData.serviceId}
                    onChange={(e) => setFormData({ ...formData, serviceId: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  >
                    <option value="">Sélectionner un service</option>
                    {services.map(service => (
                      <option key={service.id} value={service.id}>
                        {service.nom}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Date d'Entrée</label>
                  <input
                    type="date"
                    required
                    value={formData.dateEntree}
                    onChange={(e) => setFormData({ ...formData, dateEntree: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Date de Sortie</label>
                  <input
                    type="date"
                    value={formData.dateSortie}
                    onChange={(e) => setFormData({ ...formData, dateSortie: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Motif</label>
                <input
                  type="text"
                  value={formData.motif}
                  onChange={(e) => setFormData({ ...formData, motif: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Diagnostic</label>
                <textarea
                  value={formData.diagnostic}
                  onChange={(e) => setFormData({ ...formData, diagnostic: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              <div className="flex justify-end gap-2 mt-6">
                <Button variant="ghost" size="md" type="button" onClick={closeModal}>
                  Annuler
                </Button>
                <Button variant="primary" size="md" type="submit">
                  {editingSejour ? 'Mettre à jour' : 'Créer'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
