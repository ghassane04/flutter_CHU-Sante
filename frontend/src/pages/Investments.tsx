import React, { useState, useEffect } from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';
import { Plus, TrendingUp, Calendar, DollarSign, AlertCircle, Edit2, Trash2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, Investment } from '../services/api';

export function Investments() {
  const [investments, setInvestments] = useState<Investment[]>([]);
  const [selectedInvestment, setSelectedInvestment] = useState<Investment | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [editingInvestment, setEditingInvestment] = useState<Investment | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    nom: '',
    categorie: '',
    description: '',
    montant: 0,
    dateInvestissement: '',
    dateFinPrevue: '',
    statut: 'PLANIFIE' as 'PLANIFIE' | 'EN_COURS' | 'TERMINE' | 'ANNULE',
    fournisseur: '',
    responsable: '',
    retourInvestissement: 0
  });

  useEffect(() => {
    loadInvestments();
  }, []);

  const loadInvestments = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getInvestments();
      setInvestments(data);
    } catch (err: any) {
      console.error('Erreur lors du chargement des investissements:', err);
      const errorMessage = err.message || 'Impossible de charger les investissements';
      setError(`${errorMessage}. Vérifiez que vous êtes connecté et que le backend est démarré.`);
      setInvestments([]);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const styles: Record<string, string> = {
      'PLANIFIE': 'bg-gray-100 text-gray-800',
      'EN_COURS': 'bg-green-100 text-green-800',
      'TERMINE': 'bg-blue-100 text-blue-800',
      'ANNULE': 'bg-red-100 text-red-800',
    };
    const labels: Record<string, string> = {
      'PLANIFIE': 'En attente',
      'EN_COURS': 'En cours',
      'TERMINE': 'Terminé',
      'ANNULE': 'Annulé',
    };
    return (
      <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[status] || 'bg-gray-100 text-gray-800'}`}>
        {labels[status] || status}
      </span>
    );
  };

  const getRiskBadge = (risk: string) => {
    const styles = {
      low: 'bg-green-100 text-green-800',
      medium: 'bg-orange-100 text-orange-800',
      high: 'bg-red-100 text-red-800',
    };
    const labels = {
      low: 'Faible',
      medium: 'Moyen',
      high: 'Élevé',
    };
    return (
      <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[risk as keyof typeof styles]}`}>
        Risque {labels[risk as keyof typeof labels]}
      </span>
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingInvestment) {
        await api.updateInvestment(editingInvestment.id, {
          nom: formData.nom,
          categorie: formData.categorie,
          description: formData.description,
          montant: formData.montant,
          dateInvestissement: formData.dateInvestissement,
          dateFinPrevue: formData.dateFinPrevue,
          statut: formData.statut,
          fournisseur: formData.fournisseur,
          responsable: formData.responsable,
          retourInvestissement: formData.retourInvestissement
        });
      } else {
        await api.createInvestment({
          nom: formData.nom,
          categorie: formData.categorie,
          description: formData.description,
          montant: formData.montant,
          dateInvestissement: formData.dateInvestissement,
          dateFinPrevue: formData.dateFinPrevue,
          statut: formData.statut,
          fournisseur: formData.fournisseur,
          responsable: formData.responsable,
          retourInvestissement: formData.retourInvestissement
        });
      }
      await loadInvestments();
      closeEditModal();
    } catch (err: any) {
      console.error('Erreur lors de la sauvegarde:', err);
      alert('Erreur lors de la sauvegarde de l\'investissement');
    }
  };

  const handleDelete = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer cet investissement ?')) {
      try {
        await api.deleteInvestment(id);
        await loadInvestments();
      } catch (err: any) {
        console.error('Erreur lors de la suppression:', err);
        alert('Erreur lors de la suppression de l\'investissement');
      }
    }
  };

  const openEditModal = (investment?: Investment) => {
    if (investment) {
      setEditingInvestment(investment);
      setFormData({
        nom: investment.nom,
        categorie: investment.categorie,
        description: investment.description || '',
        montant: investment.montant,
        dateInvestissement: investment.dateInvestissement,
        dateFinPrevue: investment.dateFinPrevue || '',
        statut: investment.statut,
        fournisseur: investment.fournisseur || '',
        responsable: investment.responsable || '',
        retourInvestissement: investment.retourInvestissement || 0
      });
    } else {
      setEditingInvestment(null);
      setFormData({
        nom: '',
        categorie: '',
        description: '',
        montant: 0,
        dateInvestissement: new Date().toISOString().split('T')[0],
        dateFinPrevue: '',
        statut: 'PLANIFIE',
        fournisseur: '',
        responsable: '',
        retourInvestissement: 0
      });
    }
    setIsEditModalOpen(true);
  };

  const closeEditModal = () => {
    setIsEditModalOpen(false);
    setEditingInvestment(null);
    setFormData({
      nom: '',
      categorie: '',
      description: '',
      montant: 0,
      dateInvestissement: '',
      dateFinPrevue: '',
      statut: 'PLANIFIE',
      fournisseur: '',
      responsable: '',
      retourInvestissement: 0
    });
  };

  const getStatusLabel = (statut: string) => {
    const labels: Record<string, string> = {
      'PLANIFIE': 'En attente',
      'EN_COURS': 'En cours',
      'TERMINE': 'Terminé',
      'ANNULE': 'Annulé'
    };
    return labels[statut] || statut;
  };

  const budgetData = investments.reduce((acc, inv) => {
    const existing = acc.find(item => item.name === inv.categorie);
    if (existing) {
      existing.value += inv.montant;
    } else {
      acc.push({ 
        name: inv.categorie, 
        value: inv.montant, 
        color: ['#0B6FB0', '#17A2A6', '#48BB78', '#F6AD55', '#ED8936'][acc.length % 5]
      });
    }
    return acc;
  }, [] as Array<{ name: string; value: number; color: string }>);

  const totalBudget = investments.reduce((sum, inv) => sum + inv.montant, 0);
  const totalROI = investments.reduce((sum, inv) => sum + (inv.montant * (inv.retourInvestissement || 0) / 100), 0);
  const activeCount = investments.filter(i => i.statut === 'EN_COURS').length;

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des investissements...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-gray-900 mb-2">Investissements</h1>
          <p className="text-gray-600">Gestion du portefeuille d'investissements hospitaliers</p>
        </div>
        <Button variant="primary" size="md" onClick={() => openEditModal()}>
          <Plus className="w-5 h-5 mr-2" />
          Nouvel investissement
        </Button>
      </div>

      {/* Affichage des erreurs */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <div className="flex-1">
              <p className="text-red-800 font-medium mb-2">Erreur de chargement</p>
              <p className="text-red-600 text-sm mb-3">{error}</p>
              <Button variant="ghost" size="sm" onClick={loadInvestments}>
                Réessayer
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center gap-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <DollarSign className="w-6 h-6 text-[#0B6FB0]" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Budget total disponible</p>
              <p className="text-2xl font-bold text-gray-900 transition-all duration-300">
                {totalBudget.toLocaleString('fr-FR')} €
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center gap-4">
            <div className="p-3 bg-green-100 rounded-lg">
              <TrendingUp className="w-6 h-6 text-green-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">ROI estimé total</p>
              <p className="text-2xl font-bold text-gray-900 transition-all duration-300">
                {totalROI.toLocaleString('fr-FR')} €
              </p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center gap-4">
            <div className="p-3 bg-orange-100 rounded-lg">
              <Calendar className="w-6 h-6 text-orange-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Projets actifs</p>
              <p className="text-2xl font-bold text-gray-900 transition-all duration-300">
                {activeCount}
              </p>
            </div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Budget Distribution */}
        <Card>
          <h3 className="text-gray-900 mb-4">Répartition du budget</h3>
          {budgetData.length > 0 ? (
          <>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={budgetData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {budgetData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => `${value.toLocaleString('fr-FR')} €`} />
              </PieChart>
            </ResponsiveContainer>
            <div className="mt-4 space-y-2">
              {budgetData.map((item, index) => (
                <div key={index} className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }}></div>
                    <span className="text-gray-700">{item.name}</span>
                  </div>
                  <span className="font-medium text-gray-900">
                    {item.value.toLocaleString('fr-FR')} €
                  </span>
                </div>
              ))}
            </div>
          </>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <p>Aucune donnée disponible</p>
            </div>
          )}
        </Card>

        {/* Investment List */}
        <div className="lg:col-span-2 space-y-4">
          {investments.length === 0 && !error ? (
            <Card padding="lg">
              <div className="text-center py-12">
                <DollarSign className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <p className="text-gray-500 mb-4">Aucun investissement trouvé</p>
                <Button variant="primary" size="sm" onClick={() => openEditModal()}>
                  <Plus className="w-4 h-4 mr-2" />
                  Créer le premier investissement
                </Button>
              </div>
            </Card>
          ) : (
            investments.map((investment) => (
            <Card key={investment.id} padding="md">
              <div className="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                <div className="flex-1">
                  <div className="flex flex-wrap items-center gap-2 mb-2">
                    <h3 className="font-semibold text-gray-900">{investment.nom}</h3>
                    {getStatusBadge(investment.statut)}
                  </div>
                  <p className="text-sm text-gray-600 mb-3">{investment.description}</p>
                  
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <p className="text-xs text-gray-500">Montant</p>
                      <p className="font-medium text-gray-900">
                        {investment.montant.toLocaleString('fr-FR')} €
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">ROI estimé</p>
                      <p className="font-medium text-green-600">+{investment.retourInvestissement || 0}%</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">Catégorie</p>
                      <p className="font-medium text-gray-900">{investment.categorie}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">Échéance</p>
                      <p className="font-medium text-gray-900">
                        {investment.dateFinPrevue ? new Date(investment.dateFinPrevue).toLocaleDateString('fr-FR') : 'N/A'}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="flex flex-col gap-2">
                  {investment.statut === 'EN_COURS' && getRiskBadge('medium')}
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => {
                        setSelectedInvestment(investment);
                        setIsModalOpen(true);
                      }}
                    >
                      Voir détails
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => openEditModal(investment)}
                    >
                      <Edit2 className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="danger"
                      size="sm"
                      onClick={() => handleDelete(investment.id)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          ))
          )}
        </div>
      </div>

      {/* Detail Modal */}
      {selectedInvestment && (
        <Modal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          title={selectedInvestment.nom}
          size="lg"
          footer={
            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => setIsModalOpen(false)} fullWidth>
                Fermer
              </Button>
              <Button variant="primary" fullWidth onClick={() => {
                setIsModalOpen(false);
                openEditModal(selectedInvestment);
              }}>
                Modifier
              </Button>
            </div>
          }
        >
          <div className="space-y-6">
            <div>
              <h4 className="font-medium text-gray-900 mb-2">Description</h4>
              <p className="text-gray-700">{selectedInvestment.description || 'Aucune description'}</p>
            </div>

            <div className="grid grid-cols-2 gap-6">
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Informations financières</h4>
                <div className="space-y-3">
                  <div>
                    <p className="text-sm text-gray-600">Montant total</p>
                    <p className="text-lg font-semibold text-gray-900">
                      {selectedInvestment.montant.toLocaleString('fr-FR')} €
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">ROI estimé</p>
                    <p className="text-lg font-semibold text-green-600">
                      +{selectedInvestment.retourInvestissement || 0}% ({(selectedInvestment.montant * (selectedInvestment.retourInvestissement || 0) / 100).toLocaleString('fr-FR')} €)
                    </p>
                  </div>
                  {selectedInvestment.fournisseur && (
                    <div>
                      <p className="text-sm text-gray-600">Fournisseur</p>
                      <p className="font-medium text-gray-900">{selectedInvestment.fournisseur}</p>
                    </div>
                  )}
                </div>
              </div>

              <div>
                <h4 className="font-medium text-gray-900 mb-2">Planning</h4>
                <div className="space-y-3">
                  <div>
                    <p className="text-sm text-gray-600">Date début</p>
                    <p className="text-lg font-semibold text-gray-900">
                      {new Date(selectedInvestment.dateInvestissement).toLocaleDateString('fr-FR', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                      })}
                    </p>
                  </div>
                  {selectedInvestment.dateFinPrevue && (
                    <div>
                      <p className="text-sm text-gray-600">Échéance</p>
                      <p className="text-lg font-semibold text-gray-900">
                        {new Date(selectedInvestment.dateFinPrevue).toLocaleDateString('fr-FR', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                        })}
                      </p>
                    </div>
                  )}
                  <div>
                    <p className="text-sm text-gray-600">Statut</p>
                    <div className="mt-1">{getStatusBadge(selectedInvestment.statut)}</div>
                  </div>
                  {selectedInvestment.responsable && (
                    <div>
                      <p className="text-sm text-gray-600">Responsable</p>
                      <p className="font-medium text-gray-900">{selectedInvestment.responsable}</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </Modal>
      )}

      {/* Edit Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={closeEditModal}
        title={editingInvestment ? 'Modifier l\'investissement' : 'Nouvel investissement'}
        footer={
          <div className="flex gap-3">
            <Button variant="ghost" onClick={closeEditModal} fullWidth>
              Annuler
            </Button>
            <Button variant="primary" onClick={handleSubmit} fullWidth>
              {editingInvestment ? 'Modifier' : 'Créer'}
            </Button>
          </div>
        }
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Nom de l'investissement"
            value={formData.nom}
            onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
            placeholder="Ex: Nouveau scanner IRM"
            required
          />
          <Input
            label="Catégorie"
            value={formData.categorie}
            onChange={(e) => setFormData({ ...formData, categorie: e.target.value })}
            placeholder="Ex: Équipement médical"
            required
          />
          <Input
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Description du projet"
          />
          <Input
            label="Montant (€)"
            type="number"
            value={formData.montant}
            onChange={(e) => setFormData({ ...formData, montant: Number(e.target.value) })}
            placeholder="0"
            required
            min="0"
          />
          <Input
            label="ROI estimé (%)"
            type="number"
            value={formData.retourInvestissement}
            onChange={(e) => setFormData({ ...formData, retourInvestissement: Number(e.target.value) })}
            placeholder="0"
            min="0"
            max="100"
          />
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date de début"
              type="date"
              value={formData.dateInvestissement}
              onChange={(e) => setFormData({ ...formData, dateInvestissement: e.target.value })}
              required
            />
            <Input
              label="Date de fin prévue"
              type="date"
              value={formData.dateFinPrevue}
              onChange={(e) => setFormData({ ...formData, dateFinPrevue: e.target.value })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Statut</label>
            <select
              value={formData.statut}
              onChange={(e) => setFormData({ ...formData, statut: e.target.value as any })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="PLANIFIE">Planifié</option>
              <option value="EN_COURS">En cours</option>
              <option value="TERMINE">Terminé</option>
              <option value="ANNULE">Annulé</option>
            </select>
          </div>
          <Input
            label="Fournisseur"
            value={formData.fournisseur}
            onChange={(e) => setFormData({ ...formData, fournisseur: e.target.value })}
            placeholder="Nom du fournisseur"
          />
          <Input
            label="Responsable"
            value={formData.responsable}
            onChange={(e) => setFormData({ ...formData, responsable: e.target.value })}
            placeholder="Nom du responsable"
          />
        </form>
      </Modal>
    </div>
  );
}
