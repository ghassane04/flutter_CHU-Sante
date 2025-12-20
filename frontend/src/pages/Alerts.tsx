import React, { useState, useEffect } from 'react';
import { AlertTriangle, AlertCircle, Info, CheckCircle, Filter, SortAsc, Plus, Edit2, Trash2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, Alert } from '../services/api';

export function Alerts() {
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [selectedAlert, setSelectedAlert] = useState<Alert | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [editingAlert, setEditingAlert] = useState<Alert | null>(null);
  const [filterSeverity, setFilterSeverity] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [showFilters, setShowFilters] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    titre: '',
    message: '',
    type: 'INFO' as 'SUCCESS' | 'INFO' | 'WARNING' | 'ERROR',
    priorite: 'MOYENNE' as 'BASSE' | 'MOYENNE' | 'HAUTE' | 'CRITIQUE',
    categorie: '',
    assigneeA: '',
    commentaire: ''
  });

  useEffect(() => {
    loadAlerts();
  }, []);

  const loadAlerts = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getAlerts();
      setAlerts(data);
    } catch (err: any) {
      console.error('Erreur lors du chargement des alertes:', err);
      const errorMessage = err.message || 'Impossible de charger les alertes';
      setError(`${errorMessage}. Vérifiez que vous êtes connecté et que le backend est démarré.`);
      setAlerts([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingAlert) {
        await api.updateAlert(editingAlert.id, {
          titre: formData.titre,
          message: formData.message,
          type: formData.type,
          priorite: formData.priorite,
          categorie: formData.categorie,
          assigneeA: formData.assigneeA,
          commentaire: formData.commentaire
        });
      } else {
        await api.createAlert({
          titre: formData.titre,
          message: formData.message,
          type: formData.type,
          priorite: formData.priorite,
          categorie: formData.categorie,
          lu: false,
          resolu: false,
          assigneeA: formData.assigneeA,
          commentaire: formData.commentaire
        });
      }
      await loadAlerts();
      closeEditModal();
    } catch (err: any) {
      console.error('Erreur lors de la sauvegarde:', err);
      alert('Erreur lors de la sauvegarde de l\'alerte');
    }
  };

  const handleDelete = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer cette alerte ?')) {
      try {
        await api.deleteAlert(id);
        await loadAlerts();
      } catch (err: any) {
        console.error('Erreur lors de la suppression:', err);
        alert('Erreur lors de la suppression de l\'alerte');
      }
    }
  };

  const handleMarkAsRead = async (id: number) => {
    try {
      await api.markAlertAsRead(id);
      await loadAlerts();
    } catch (err: any) {
      console.error('Erreur:', err);
    }
  };

  const handleMarkAsResolved = async (id: number) => {
    try {
      await api.markAlertAsResolved(id);
      await loadAlerts();
    } catch (err: any) {
      console.error('Erreur:', err);
    }
  };

  const openEditModal = (alert?: Alert) => {
    if (alert) {
      setEditingAlert(alert);
      setFormData({
        titre: alert.titre,
        message: alert.message,
        type: alert.type,
        priorite: alert.priorite,
        categorie: alert.categorie,
        assigneeA: alert.assigneeA || '',
        commentaire: alert.commentaire || ''
      });
    } else {
      setEditingAlert(null);
      setFormData({
        titre: '',
        message: '',
        type: 'INFO',
        priorite: 'MOYENNE',
        categorie: '',
        assigneeA: '',
        commentaire: ''
      });
    }
    setIsEditModalOpen(true);
  };

  const closeEditModal = () => {
    setIsEditModalOpen(false);
    setEditingAlert(null);
    setFormData({
      titre: '',
      message: '',
      type: 'INFO',
      priorite: 'MOYENNE',
      categorie: '',
      assigneeA: '',
      commentaire: ''
    });
  };

  const getSeverityIcon = (priorite: string) => {
    switch (priorite) {
      case 'CRITIQUE':
        return <AlertTriangle className="w-5 h-5 text-red-600" />;
      case 'HAUTE':
        return <AlertCircle className="w-5 h-5 text-orange-600" />;
      case 'MOYENNE':
        return <Info className="w-5 h-5 text-yellow-600" />;
      case 'BASSE':
        return <CheckCircle className="w-5 h-5 text-blue-600" />;
      default:
        return <Info className="w-5 h-5 text-gray-600" />;
    }
  };

  const getSeverityBadge = (priorite: string) => {
    const styles: Record<string, string> = {
      'CRITIQUE': 'bg-red-100 text-red-800 border-red-200',
      'HAUTE': 'bg-orange-100 text-orange-800 border-orange-200',
      'MOYENNE': 'bg-yellow-100 text-yellow-800 border-yellow-200',
      'BASSE': 'bg-blue-100 text-blue-800 border-blue-200',
    };
    const labels: Record<string, string> = {
      'CRITIQUE': 'Critique',
      'HAUTE': 'Haute',
      'MOYENNE': 'Moyenne',
      'BASSE': 'Faible',
    };
    return (
      <span className={`px-3 py-1 rounded-full text-xs font-medium border ${styles[priorite] || 'bg-gray-100 text-gray-800'}`}>
        {labels[priorite] || priorite}
      </span>
    );
  };

  const getStatusBadge = (resolu: boolean, lu: boolean) => {
    if (resolu) {
      return <span className="px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">Résolu</span>;
    }
    if (lu) {
      return <span className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">En cours</span>;
    }
    return <span className="px-3 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">Nouveau</span>;
  };

  const filteredAlerts = alerts.filter(alert => {
    if (filterSeverity !== 'all' && alert.priorite !== filterSeverity) return false;
    if (filterStatus === 'resolved' && !alert.resolu) return false;
    if (filterStatus === 'in_progress' && (alert.resolu || !alert.lu)) return false;
    if (filterStatus === 'new' && alert.lu) return false;
    return true;
  });

  const stats = {
    total: alerts.length,
    critical: alerts.filter(a => a.priorite === 'CRITIQUE').length,
    resolved: alerts.filter(a => a.resolu).length,
    resolvedRate: alerts.length > 0 ? Math.round((alerts.filter(a => a.resolu).length / alerts.length) * 100) : 0,
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des alertes...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-gray-900 mb-2">Alertes & Anomalies</h1>
          <p className="text-gray-600">Gestion des alertes et anomalies financières détectées</p>
        </div>
        <Button variant="primary" size="md" onClick={() => openEditModal()}>
          <Plus className="w-5 h-5 mr-2" />
          Nouvelle alerte
        </Button>
      </div>

      {/* Affichage des erreurs */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <div className="flex-1">
              <p className="text-red-800 font-medium mb-2">Erreur de chargement</p>
              <p className="text-red-600 text-sm mb-3">{error}</p>
              <Button variant="ghost" size="sm" onClick={loadAlerts}>
                Réessayer
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card padding="md">
          <p className="text-sm text-gray-600 mb-1">Total alertes</p>
          <p className="text-2xl font-bold text-gray-900 transition-all duration-300">{stats.total}</p>
        </Card>
        <Card padding="md">
          <p className="text-sm text-gray-600 mb-1">Critiques</p>
          <p className="text-2xl font-bold text-red-600 transition-all duration-300">{stats.critical}</p>
        </Card>
        <Card padding="md">
          <p className="text-sm text-gray-600 mb-1">Résolues</p>
          <p className="text-2xl font-bold text-green-600 transition-all duration-300">{stats.resolved}</p>
        </Card>
        <Card padding="md">
          <p className="text-sm text-gray-600 mb-1">Taux résolution</p>
          <p className="text-2xl font-bold text-blue-600 transition-all duration-300">{stats.resolvedRate}%</p>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-gray-900">Filtres</h3>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="md:hidden flex items-center gap-2 text-sm text-[#0B6FB0] font-medium"
          >
            <Filter className="w-4 h-4" />
            {showFilters ? 'Masquer' : 'Afficher'}
          </button>
        </div>
        <div className={`grid grid-cols-1 md:grid-cols-3 gap-4 ${showFilters ? 'block' : 'hidden md:grid'}`}>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Date</label>
            <input type="date" className="input w-full" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Priorité</label>
            <select
              value={filterSeverity}
              onChange={(e) => setFilterSeverity(e.target.value)}
              className="input w-full"
            >
              <option value="all">Toutes</option>
              <option value="CRITIQUE">Critique</option>
              <option value="HAUTE">Haute</option>
              <option value="MOYENNE">Moyenne</option>
              <option value="BASSE">Faible</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Statut</label>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="input w-full"
            >
              <option value="all">Tous</option>
              <option value="new">Nouveau</option>
              <option value="in_progress">En cours</option>
              <option value="resolved">Résolu</option>
            </select>
          </div>
        </div>
      </Card>

      {/* Alerts List */}
      <Card padding="none">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-4 text-left">
                  <button className="flex items-center gap-2 text-sm font-medium text-gray-700 hover:text-gray-900">
                    Date
                    <SortAsc className="w-4 h-4" />
                  </button>
                </th>
                <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Service</th>
                <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Message</th>
                <th className="px-6 py-4 text-right text-sm font-medium text-gray-700">Montant</th>
                <th className="px-6 py-4 text-center text-sm font-medium text-gray-700">Gravité</th>
                <th className="px-6 py-4 text-center text-sm font-medium text-gray-700">Statut</th>
                <th className="px-6 py-4 text-right text-sm font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredAlerts.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center">
                    <AlertCircle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                    <p className="text-gray-500">Aucune alerte trouvée</p>
                  </td>
                </tr>
              ) : (
                filteredAlerts.map((alert) => (
                <tr key={alert.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {new Date(alert.createdAt).toLocaleDateString('fr-FR')}
                    <br />
                    <span className="text-xs text-gray-500">
                      {new Date(alert.createdAt).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </td>
                  <td className="px-6 py-4 font-medium text-gray-900">{alert.categorie}</td>
                  <td className="px-6 py-4">
                    <div className="flex items-start gap-2">
                      {getSeverityIcon(alert.priorite)}
                      <div>
                        <p className="text-sm font-medium text-gray-900">{alert.titre}</p>
                        <p className="text-xs text-gray-600">{alert.message}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right font-medium text-gray-900">
                    {alert.type === 'ERROR' ? <span className="text-red-600">Erreur</span> : 
                     alert.type === 'WARNING' ? <span className="text-orange-600">Attention</span> :
                     alert.type === 'SUCCESS' ? <span className="text-green-600">Succès</span> : 
                     <span className="text-blue-600">Info</span>}
                  </td>
                  <td className="px-6 py-4 text-center">
                    {getSeverityBadge(alert.priorite)}
                  </td>
                  <td className="px-6 py-4 text-center">
                    {getStatusBadge(alert.resolu, alert.lu)}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      {!alert.lu && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleMarkAsRead(alert.id)}
                        >
                          Lire
                        </Button>
                      )}
                      {!alert.resolu && alert.lu && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleMarkAsResolved(alert.id)}
                        >
                          Résoudre
                        </Button>
                      )}
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => {
                          setSelectedAlert(alert);
                          setIsModalOpen(true);
                        }}
                      >
                        Détails
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEditModal(alert)}
                      >
                        <Edit2 className="w-4 h-4" />
                      </Button>
                      <Button
                        variant="danger"
                        size="sm"
                        onClick={() => handleDelete(alert.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Detail Modal */}
      {selectedAlert && (
        <Modal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          title={selectedAlert.titre}
          size="lg"
          footer={
            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => setIsModalOpen(false)} fullWidth>
                Fermer
              </Button>
              {!selectedAlert.resolu && (
                <Button variant="primary" fullWidth onClick={() => {
                  handleMarkAsResolved(selectedAlert.id);
                  setIsModalOpen(false);
                }}>
                  Marquer comme résolu
                </Button>
              )}
            </div>
          }
        >
          <div className="space-y-6">
            {/* Header info */}
            <div className="flex flex-wrap items-center gap-3">
              {getSeverityBadge(selectedAlert.priorite)}
              {getStatusBadge(selectedAlert.resolu, selectedAlert.lu)}
              <span className="text-sm text-gray-600">
                {new Date(selectedAlert.createdAt).toLocaleDateString('fr-FR', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </span>
            </div>

            {/* Details */}
            <div>
              <h4 className="font-medium text-gray-900 mb-2">Message</h4>
              <p className="text-gray-700">{selectedAlert.message}</p>
            </div>

            <div className="grid grid-cols-2 gap-6">
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Catégorie</h4>
                <p className="text-lg text-gray-700">{selectedAlert.categorie}</p>
              </div>
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Type</h4>
                <p className="text-lg font-semibold text-gray-900">
                  {selectedAlert.type}
                </p>
              </div>
            </div>

            {selectedAlert.assigneeA && (
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Assigné à</h4>
                <p className="text-gray-700">{selectedAlert.assigneeA}</p>
              </div>
            )}

            {selectedAlert.commentaire && (
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Commentaire</h4>
                <div className="p-4 bg-gray-50 rounded-lg">
                  <p className="text-gray-700">{selectedAlert.commentaire}</p>
                </div>
              </div>
            )}

            {selectedAlert.dateResolution && (
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Date de résolution</h4>
                <p className="text-gray-700">
                  {new Date(selectedAlert.dateResolution).toLocaleDateString('fr-FR', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                  })}
                </p>
              </div>
            )}
          </div>
        </Modal>
      )}

      {/* Edit Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={closeEditModal}
        title={editingAlert ? 'Modifier l\'alerte' : 'Nouvelle alerte'}
        footer={
          <div className="flex gap-3">
            <Button variant="ghost" onClick={closeEditModal} fullWidth>
              Annuler
            </Button>
            <Button variant="primary" onClick={handleSubmit} fullWidth>
              {editingAlert ? 'Modifier' : 'Créer'}
            </Button>
          </div>
        }
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Titre"
            value={formData.titre}
            onChange={(e) => setFormData({ ...formData, titre: e.target.value })}
            placeholder="Titre de l'alerte"
            required
          />
          <Input
            label="Message"
            value={formData.message}
            onChange={(e) => setFormData({ ...formData, message: e.target.value })}
            placeholder="Message détaillé"
            required
          />
          <Input
            label="Catégorie"
            value={formData.categorie}
            onChange={(e) => setFormData({ ...formData, categorie: e.target.value })}
            placeholder="Ex: Budget, Ressources, Maintenance"
            required
          />
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Type</label>
              <select
                value={formData.type}
                onChange={(e) => setFormData({ ...formData, type: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              >
                <option value="INFO">Information</option>
                <option value="SUCCESS">Succès</option>
                <option value="WARNING">Attention</option>
                <option value="ERROR">Erreur</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Priorité</label>
              <select
                value={formData.priorite}
                onChange={(e) => setFormData({ ...formData, priorite: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              >
                <option value="BASSE">Faible</option>
                <option value="MOYENNE">Moyenne</option>
                <option value="HAUTE">Haute</option>
                <option value="CRITIQUE">Critique</option>
              </select>
            </div>
          </div>
          <Input
            label="Assigné à"
            value={formData.assigneeA}
            onChange={(e) => setFormData({ ...formData, assigneeA: e.target.value })}
            placeholder="Nom du responsable"
          />
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Commentaire</label>
            <textarea
              value={formData.commentaire}
              onChange={(e) => setFormData({ ...formData, commentaire: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 min-h-[100px] resize-none"
              placeholder="Commentaire ou notes..."
            />
          </div>
        </form>
      </Modal>
    </div>
  );
}
