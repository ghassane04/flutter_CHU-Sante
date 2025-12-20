import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Building2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, Service } from '../services/api';

export function Services() {
  const [services, setServices] = useState<Service[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingService, setEditingService] = useState<Service | null>(null);
  const [formData, setFormData] = useState({ nom: '', type: '', description: '', capacite: 0, responsable: '' });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadServices();
  }, []);

  const loadServices = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getServices();
      setServices(data);
    } catch (err: any) {
      console.error('Erreur lors du chargement des services:', err);
      const errorMessage = err.message || 'Impossible de charger les services';
      setError(`${errorMessage}. Vérifiez que vous êtes connecté et que le backend est démarré.`);
      setServices([]); // Afficher une liste vide au lieu d'une erreur bloquante
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingService) {
        await api.updateService(editingService.id, {
          nom: formData.nom,
          type: formData.type,
          description: formData.description,
          capacite: formData.capacite,
          responsable: formData.responsable
        });
      } else {
        await api.createService({
          nom: formData.nom,
          type: formData.type,
          description: formData.description,
          capacite: formData.capacite,
          responsable: formData.responsable
        });
      }
      await loadServices();
      closeModal();
    } catch (err: any) {
      console.error('Erreur lors de la sauvegarde:', err);
      alert('Erreur lors de la sauvegarde du service');
    }
  };

  const handleDelete = async (id: number) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce service ?')) {
      try {
        await api.deleteService(id);
        await loadServices();
      } catch (err: any) {
        console.error('Erreur lors de la suppression:', err);
        alert('Erreur lors de la suppression du service');
      }
    }
  };

  const openModal = (service?: Service) => {
    if (service) {
      setEditingService(service);
      setFormData({ 
        nom: service.nom, 
        type: service.type, 
        description: service.description || '',
        capacite: service.capacite || 0,
        responsable: service.responsable || ''
      });
    } else {
      setEditingService(null);
      setFormData({ nom: '', type: '', description: '', capacite: 0, responsable: '' });
    }
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingService(null);
    setFormData({ nom: '', type: '', description: '', capacite: 0, responsable: '' });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des services...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-gray-900 mb-2">Gestion des services</h1>
          <p className="text-gray-600">Liste et suivi des services hospitaliers</p>
        </div>
        <Button variant="primary" size="md" onClick={() => openModal()}>
          <Plus className="w-5 h-5 mr-2" />
          Nouveau service
        </Button>
      </div>

      {/* Affichage des erreurs */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <div className="flex-1">
              <p className="text-red-800 font-medium mb-2">Erreur de chargement</p>
              <p className="text-red-600 text-sm mb-3">{error}</p>
              <Button variant="ghost" size="sm" onClick={loadServices}>
                Réessayer
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Services Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {services.map(service => {
          const occupationPercent = service.capacite && service.litsDisponibles !== undefined
            ? Math.round(((service.capacite - service.litsDisponibles) / service.capacite) * 100)
            : 0;
          const isHighOccupation = occupationPercent > 85;

          return (
            <Card key={service.id} padding="md">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="p-3 bg-blue-100 rounded-lg">
                    <Building2 className="w-6 h-6 text-[#0B6FB0]" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">{service.nom}</h3>
                    <p className="text-sm text-gray-600">{service.type}</p>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                {service.description && (
                  <p className="text-sm text-gray-600">{service.description}</p>
                )}

                {service.capacite !== undefined && service.litsDisponibles !== undefined && (
                  <div>
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-gray-600">Occupation</span>
                      <span className={`font-medium ${
                        isHighOccupation ? 'text-orange-600' : 'text-gray-900'
                      }`}>
                        {occupationPercent}%
                      </span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full transition-all ${
                          isHighOccupation ? 'bg-orange-500' : 'bg-blue-500'
                        }`}
                        style={{ width: `${Math.min(occupationPercent, 100)}%` }}
                      ></div>
                    </div>
                  </div>
                )}

                <div className="pt-3 border-t border-gray-200">
                  {service.capacite !== undefined && (
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-600">Capacité totale</span>
                      <span className="font-medium text-gray-900">
                        {service.capacite} lits
                      </span>
                    </div>
                  )}
                  {service.litsDisponibles !== undefined && (
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-600">Lits disponibles</span>
                      <span className="font-medium text-gray-900">
                        {service.litsDisponibles} lits
                      </span>
                    </div>
                  )}
                  {service.responsable && (
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Responsable</span>
                      <span className="font-medium text-gray-900">
                        {service.responsable}
                      </span>
                    </div>
                  )}
                </div>

                <div className="flex gap-2 pt-3">
                  <Button
                    variant="ghost"
                    size="sm"
                    fullWidth
                    onClick={() => openModal(service)}
                  >
                    <Edit2 className="w-4 h-4 mr-2" />
                    Modifier
                  </Button>
                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(service.id)}
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </Card>
          );
        })}
        
        {/* Message si aucun service */}
        {!loading && services.length === 0 && !error && (
          <div className="col-span-full text-center py-12">
            <Building2 className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500 mb-4">Aucun service trouvé</p>
            <Button variant="primary" size="sm" onClick={() => openModal()}>
              <Plus className="w-4 h-4 mr-2" />
              Créer le premier service
            </Button>
          </div>
        )}
      </div>

      {/* Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={closeModal}
        title={editingService ? 'Modifier le service' : 'Nouveau service'}
        footer={
          <div className="flex gap-3">
            <Button variant="ghost" onClick={closeModal} fullWidth>
              Annuler
            </Button>
            <Button variant="primary" onClick={handleSubmit} fullWidth>
              {editingService ? 'Modifier' : 'Créer'}
            </Button>
          </div>
        }
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Nom du service"
            value={formData.nom}
            onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
            placeholder="Ex: Urgences"
            required
          />
          <Input
            label="Type"
            value={formData.type}
            onChange={(e) => setFormData({ ...formData, type: e.target.value })}
            placeholder="Ex: Médecine d'urgence"
            required
          />
          <Input
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Description du service"
          />
          <Input
            label="Capacité (nombre de lits)"
            type="number"
            value={formData.capacite}
            onChange={(e) => setFormData({ ...formData, capacite: Number(e.target.value) })}
            placeholder="0"
            min="0"
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
