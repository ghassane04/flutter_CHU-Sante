import React, { useState, useEffect } from 'react';
import { FileText, Plus, Search, Edit, Trash2, Calendar, DollarSign, User, Hash } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, ActeMedical, Sejour } from '../services/api';

export function ActesMedicauxPage() {
  const [actes, setActes] = useState<ActeMedical[]>([]);
  const [sejours, setSejours] = useState<Sejour[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingActe, setEditingActe] = useState<ActeMedical | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [formData, setFormData] = useState({
    sejourId: '',
    code: '',
    libelle: '',
    type: 'CONSULTATION',
    dateRealisation: new Date().toISOString().split('T')[0],
    tarif: '',
    medecin: '',
    notes: ''
  });

  useEffect(() => {
    loadActes();
    loadSejours();
  }, []);

  const loadSejours = async () => {
    try {
      const data = await api.getSejours();
      setSejours(data);
    } catch (err) {
      console.error('Erreur lors du chargement des séjours:', err);
    }
  };

  const loadActes = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getActes();
      setActes(data);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des actes médicaux');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const acteData = {
        ...formData,
        sejourId: parseInt(formData.sejourId),
        tarif: parseFloat(formData.tarif),
        dateRealisation: formData.dateRealisation + 'T00:00:00'
      };

      if (editingActe) {
        await api.updateActe(editingActe.id, acteData);
      } else {
        await api.createActe(acteData);
      }
      
      setIsModalOpen(false);
      setEditingActe(null);
      setFormData({
        sejourId: '',
        code: '',
        libelle: '',
        type: 'CONSULTATION',
        dateRealisation: new Date().toISOString().split('T')[0],
        tarif: '',
        medecin: '',
        notes: ''
      });
      await loadActes();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la sauvegarde de l\'acte médical');
    }
  };

  const handleEdit = (acte: ActeMedical) => {
    setEditingActe(acte);
    setFormData({
      sejourId: acte.sejourId.toString(),
      code: acte.code,
      libelle: acte.libelle,
      type: acte.type,
      dateRealisation: acte.dateRealisation.split('T')[0],
      tarif: acte.tarif.toString(),
      medecin: acte.medecin || '',
      notes: acte.notes || ''
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet acte médical ?')) {
      try {
        await api.deleteActe(id);
        await loadActes();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression');
      }
    }
  };

  const filteredActes = actes.filter(acte => {
    const matchesSearch = 
      acte.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
      acte.libelle.toLowerCase().includes(searchQuery.toLowerCase()) ||
      acte.medecin?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = !typeFilter || acte.type === typeFilter;
    return matchesSearch && matchesType;
  });

  const types = [...new Set(actes.map(a => a.type))];

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR');
  };

  const getTypeBadge = (type: string) => {
    const badges: Record<string, string> = {
      'CONSULTATION': 'bg-blue-100 text-blue-800',
      'EXAMEN': 'bg-purple-100 text-purple-800',
      'CHIRURGIE': 'bg-red-100 text-red-800',
      'RADIOLOGIE': 'bg-green-100 text-green-800',
      'LABORATOIRE': 'bg-yellow-100 text-yellow-800',
      'TRAITEMENT': 'bg-indigo-100 text-indigo-800',
      'URGENCE': 'bg-orange-100 text-orange-800',
      'HOSPITALISATION': 'bg-gray-100 text-gray-800',
      'ANESTHESIE': 'bg-pink-100 text-pink-800'
    };
    return badges[type] || 'bg-gray-100 text-gray-800';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Actes Médicaux</h1>
          <p className="text-gray-600 mt-1">Gestion des actes médicaux et interventions</p>
        </div>
        <Button onClick={() => setIsModalOpen(true)}>
          <Plus className="w-5 h-5 mr-2" />
          Nouvel Acte
        </Button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Filters */}
      <Card className="p-4">
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Rechercher par code, libellé, médecin..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div className="min-w-[200px]">
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Tous les types</option>
              {types.map(type => (
                <option key={type} value={type}>{type}</option>
              ))}
            </select>
          </div>
        </div>
        <div className="mt-3 text-sm text-gray-600">
          {filteredActes.length} acte(s) trouvé(s)
          {typeFilter && <span className="ml-2 px-2 py-1 bg-blue-100 text-blue-700 rounded">Type: {typeFilter}</span>}
        </div>
      </Card>

      {/* Actes List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
          <p className="text-gray-600 mt-4">Chargement...</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredActes.map((acte) => (
            <Card key={acte.id} className="p-4 hover:shadow-lg transition-shadow">
              <div className="flex justify-between items-start mb-3">
                <div className="flex items-center gap-2">
                  <FileText className="w-5 h-5 text-blue-500" />
                  <div>
                    <h3 className="font-semibold text-gray-900">{acte.libelle}</h3>
                    <span className={`inline-block px-2 py-1 rounded text-xs font-medium mt-1 ${getTypeBadge(acte.type)}`}>
                      {acte.type}
                    </span>
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm mb-4">
                <div className="flex items-center text-gray-600">
                  <Hash className="w-4 h-4 mr-2" />
                  <span className="font-medium">Code: {acte.code}</span>
                </div>

                <div className="flex items-center text-gray-600">
                  <Calendar className="w-4 h-4 mr-2" />
                  <span>{formatDate(acte.dateRealisation)}</span>
                </div>

                {acte.medecin && (
                  <div className="flex items-center text-gray-600">
                    <User className="w-4 h-4 mr-2" />
                    <span>{acte.medecin}</span>
                  </div>
                )}

                <div className="flex items-center text-green-600 font-semibold">
                  <DollarSign className="w-4 h-4 mr-2" />
                  <span>{formatCurrency(acte.tarif)}</span>
                </div>

                {acte.notes && (
                  <div className="text-xs text-gray-500 pt-2 border-t">
                    {acte.notes}
                  </div>
                )}
              </div>

              <div className="flex gap-2">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => handleEdit(acte)}
                  className="flex-1"
                >
                  <Edit className="w-4 h-4 mr-1" />
                  Modifier
                </Button>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => handleDelete(acte.id)}
                  className="flex-1 text-red-600 hover:bg-red-50"
                >
                  <Trash2 className="w-4 h-4 mr-1" />
                  Supprimer
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {!loading && filteredActes.length === 0 && (
        <div className="text-center py-12">
          <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Aucun acte médical trouvé</p>
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingActe(null);
        }}
        title={editingActe ? 'Modifier l\'Acte Médical' : 'Nouvel Acte Médical'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Séjour *
            </label>
            <select
              value={formData.sejourId}
              onChange={(e) => setFormData({ ...formData, sejourId: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            >
              <option value="">Sélectionner un séjour</option>
              {sejours.map((sejour) => (
                <option key={sejour.id} value={sejour.id}>
                  Séjour #{sejour.id} - {sejour.patientNom} {sejour.patientPrenom}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Code *"
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value })}
              placeholder="Ex: CONS001"
              required
            />
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Type *
              </label>
              <select
                value={formData.type}
                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="CONSULTATION">Consultation</option>
                <option value="EXAMEN">Examen</option>
                <option value="CHIRURGIE">Chirurgie</option>
                <option value="RADIOLOGIE">Radiologie</option>
                <option value="LABORATOIRE">Laboratoire</option>
                <option value="TRAITEMENT">Traitement</option>
                <option value="URGENCE">Urgence</option>
                <option value="HOSPITALISATION">Hospitalisation</option>
                <option value="ANESTHESIE">Anesthésie</option>
              </select>
            </div>
          </div>

          <Input
            label="Libellé *"
            value={formData.libelle}
            onChange={(e) => setFormData({ ...formData, libelle: e.target.value })}
            placeholder="Description de l'acte"
            required
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date de réalisation *"
              type="date"
              value={formData.dateRealisation}
              onChange={(e) => setFormData({ ...formData, dateRealisation: e.target.value })}
              required
            />
            <Input
              label="Tarif (€) *"
              type="number"
              step="0.01"
              value={formData.tarif}
              onChange={(e) => setFormData({ ...formData, tarif: e.target.value })}
              placeholder="0.00"
              required
            />
          </div>

          <Input
            label="Médecin"
            value={formData.medecin}
            onChange={(e) => setFormData({ ...formData, medecin: e.target.value })}
            placeholder="Dr. Martin"
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Notes
            </label>
            <textarea
              value={formData.notes}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Observations, commentaires..."
            />
          </div>

          <div className="flex justify-end gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsModalOpen(false);
                setEditingActe(null);
              }}
            >
              Annuler
            </Button>
            <Button type="submit">
              {editingActe ? 'Mettre à jour' : 'Créer'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
