import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search } from 'lucide-react';
import { api, ActeMedical, Sejour } from '../services/api';
import { Button } from './ui/Button';
import { Card } from './ui/Card';

export function ActesMedicaux() {
  const [actes, setActes] = useState<ActeMedical[]>([]);
  const [sejours, setSejours] = useState<Sejour[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingActe, setEditingActe] = useState<ActeMedical | null>(null);
  const [formData, setFormData] = useState({
    sejourId: 0,
    code: '',
    libelle: '',
    dateRealisation: '',
    medecin: '',
    cout: 0
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [actesData, sejoursData] = await Promise.all([
        api.getActes(),
        api.getSejours()
      ]);
      setActes(actesData);
      setSejours(sejoursData);
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
      if (editingActe) {
        await api.updateActe(editingActe.id, formData);
      } else {
        await api.createActe(formData);
      }
      await loadData();
      closeModal();
    } catch (err) {
      alert('Erreur lors de l\'enregistrement de l\'acte médical');
      console.error(err);
    }
  };

  const handleDelete = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer cet acte médical ?')) {
      try {
        await api.deleteActe(id);
        await loadData();
      } catch (err) {
        alert('Erreur lors de la suppression de l\'acte médical');
        console.error(err);
      }
    }
  };

  const openModal = (acte?: ActeMedical) => {
    if (acte) {
      setEditingActe(acte);
      setFormData({
        sejourId: acte.sejour.id,
        code: acte.code,
        libelle: acte.libelle,
        dateRealisation: acte.dateRealisation,
        medecin: acte.medecin || '',
        cout: acte.cout
      });
    } else {
      setEditingActe(null);
      setFormData({
        sejourId: sejours[0]?.id || 0,
        code: '',
        libelle: '',
        dateRealisation: new Date().toISOString().split('T')[0],
        medecin: '',
        cout: 0
      });
    }
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingActe(null);
  };

  const filteredActes = actes.filter(acte =>
    acte.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
    acte.libelle.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (acte.medecin && acte.medecin.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const getTotalRevenue = () => {
    return actes.reduce((sum, acte) => sum + acte.cout, 0);
  };

  if (loading) {
    return <div className="flex items-center justify-center h-64">Chargement...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Gestion des Actes Médicaux</h1>
        <Button variant="primary" size="md" onClick={() => openModal()}>
          <Plus className="w-4 h-4 mr-2" />
          Nouvel Acte Médical
        </Button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="text-sm text-gray-500">Total Actes</div>
          <div className="text-2xl font-bold text-gray-900">{actes.length}</div>
        </Card>
        <Card>
          <div className="text-sm text-gray-500">Revenus Total</div>
          <div className="text-2xl font-bold text-green-600">
            {getTotalRevenue().toLocaleString('fr-FR')} €
          </div>
        </Card>
        <Card>
          <div className="text-sm text-gray-500">Coût Moyen</div>
          <div className="text-2xl font-bold text-blue-600">
            {actes.length > 0 ? (getTotalRevenue() / actes.length).toFixed(2) : '0'} €
          </div>
        </Card>
      </div>

      <Card>
        <div className="mb-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Rechercher un acte médical..."
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
                  Code
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Libellé
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Patient
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Médecin
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Coût
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredActes.map((acte) => (
                <tr key={acte.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{acte.code}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">{acte.libelle}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {acte.sejour.patient.nom} {acte.sejour.patient.prenom}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(acte.dateRealisation).toLocaleDateString('fr-FR')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {acte.medecin}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">
                    {acte.cout.toLocaleString('fr-FR')} €
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={() => openModal(acte)}
                      className="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(acte.id)}
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
              {editingActe ? 'Modifier l\'Acte Médical' : 'Nouvel Acte Médical'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Séjour</label>
                <select
                  required
                  value={formData.sejourId}
                  onChange={(e) => setFormData({ ...formData, sejourId: parseInt(e.target.value) })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                >
                  <option value="">Sélectionner un séjour</option>
                  {sejours.map(sejour => (
                    <option key={sejour.id} value={sejour.id}>
                      {sejour.patient.nom} {sejour.patient.prenom} - {sejour.service.nom}
                    </option>
                  ))}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Code</label>
                  <input
                    type="text"
                    required
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Date de Réalisation</label>
                  <input
                    type="date"
                    required
                    value={formData.dateRealisation}
                    onChange={(e) => setFormData({ ...formData, dateRealisation: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Libellé</label>
                <input
                  type="text"
                  required
                  value={formData.libelle}
                  onChange={(e) => setFormData({ ...formData, libelle: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Médecin</label>
                  <input
                    type="text"
                    value={formData.medecin}
                    onChange={(e) => setFormData({ ...formData, medecin: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Coût (€)</label>
                  <input
                    type="number"
                    required
                    min="0"
                    step="0.01"
                    value={formData.cout}
                    onChange={(e) => setFormData({ ...formData, cout: parseFloat(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 mt-6">
                <Button variant="ghost" size="md" type="button" onClick={closeModal}>
                  Annuler
                </Button>
                <Button variant="primary" size="md" type="submit">
                  {editingActe ? 'Mettre à jour' : 'Créer'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
