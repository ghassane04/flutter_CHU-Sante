import React, { useState, useEffect } from 'react';
import { Settings as SettingsIcon, Plus, Search, Edit, Trash2, Key, Type } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, Setting } from '../services/api';

export function ParametresPage() {
  const [settings, setSettings] = useState<Setting[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSetting, setEditingSetting] = useState<Setting | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [formData, setFormData] = useState({
    cle: '',
    valeur: '',
    type: 'STRING',
    description: ''
  });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getSettings();
      setSettings(data);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des paramètres');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingSetting) {
        await api.updateSetting(editingSetting.id, formData);
      } else {
        await api.createSetting(formData);
      }
      
      setIsModalOpen(false);
      setEditingSetting(null);
      setFormData({
        cle: '',
        valeur: '',
        type: 'STRING',
        description: ''
      });
      await loadSettings();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la sauvegarde du paramètre');
    }
  };

  const handleEdit = (setting: Setting) => {
    setEditingSetting(setting);
    setFormData({
      cle: setting.cle,
      valeur: setting.valeur,
      type: setting.type,
      description: setting.description || ''
    });
    setIsModalOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce paramètre ?')) {
      try {
        await api.deleteSetting(id);
        await loadSettings();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression');
      }
    }
  };

  const filteredSettings = settings.filter(setting => {
    const matchesSearch = 
      setting.cle.toLowerCase().includes(searchQuery.toLowerCase()) ||
      setting.valeur.toLowerCase().includes(searchQuery.toLowerCase()) ||
      setting.description?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = !typeFilter || setting.type === typeFilter;
    return matchesSearch && matchesType;
  });

  const types = [...new Set(settings.map(s => s.type))];

  const getTypeBadge = (type: string) => {
    const badges: Record<string, string> = {
      'STRING': 'bg-blue-100 text-blue-800',
      'NUMBER': 'bg-green-100 text-green-800',
      'BOOLEAN': 'bg-purple-100 text-purple-800',
      'JSON': 'bg-yellow-100 text-yellow-800',
      'DATE': 'bg-pink-100 text-pink-800'
    };
    return badges[type] || 'bg-gray-100 text-gray-800';
  };

  const formatValue = (value: string, type: string) => {
    if (type === 'BOOLEAN') {
      return value === 'true' ? '✓ Oui' : '✗ Non';
    }
    if (value.length > 50) {
      return value.substring(0, 50) + '...';
    }
    return value;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Paramètres Système</h1>
          <p className="text-gray-600 mt-1">Configuration et gestion des paramètres de l'application</p>
        </div>
        <Button onClick={() => setIsModalOpen(true)}>
          <Plus className="w-5 h-5 mr-2" />
          Nouveau Paramètre
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
              placeholder="Rechercher par clé, valeur, description..."
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
          {filteredSettings.length} paramètre(s) trouvé(s)
          {typeFilter && <span className="ml-2 px-2 py-1 bg-blue-100 text-blue-700 rounded">Type: {typeFilter}</span>}
        </div>
      </Card>

      {/* Settings List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
          <p className="text-gray-600 mt-4">Chargement...</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredSettings.map((setting) => (
            <Card key={setting.id} className="p-4 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <Key className="w-5 h-5 text-blue-500" />
                    <div>
                      <h3 className="font-semibold text-gray-900 text-lg">{setting.cle}</h3>
                      <span className={`inline-block px-2 py-1 rounded text-xs font-medium ${getTypeBadge(setting.type)}`}>
                        {setting.type}
                      </span>
                    </div>
                  </div>

                  <div className="ml-8 space-y-2">
                    <div className="flex items-start gap-2">
                      <Type className="w-4 h-4 text-gray-400 mt-1 flex-shrink-0" />
                      <div>
                        <span className="text-sm text-gray-600 font-medium">Valeur: </span>
                        <span className="text-sm text-gray-900 font-mono bg-gray-50 px-2 py-1 rounded">
                          {formatValue(setting.valeur, setting.type)}
                        </span>
                      </div>
                    </div>

                    {setting.description && (
                      <p className="text-sm text-gray-600">
                        <span className="font-medium">Description: </span>
                        {setting.description}
                      </p>
                    )}

                    {setting.updatedAt && (
                      <p className="text-xs text-gray-400">
                        Dernière modification: {new Date(setting.updatedAt).toLocaleString('fr-FR')}
                      </p>
                    )}
                  </div>
                </div>

                <div className="flex gap-2 ml-4">
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => handleEdit(setting)}
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => handleDelete(setting.id)}
                    className="text-red-600 hover:bg-red-50"
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {!loading && filteredSettings.length === 0 && (
        <div className="text-center py-12">
          <SettingsIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Aucun paramètre trouvé</p>
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingSetting(null);
        }}
        title={editingSetting ? 'Modifier le Paramètre' : 'Nouveau Paramètre'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Clé *"
            value={formData.cle}
            onChange={(e) => setFormData({ ...formData, cle: e.target.value })}
            placeholder="Ex: app.nom, hospital.telephone"
            disabled={!!editingSetting}
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
              <option value="STRING">Texte (STRING)</option>
              <option value="NUMBER">Nombre (NUMBER)</option>
              <option value="BOOLEAN">Booléen (BOOLEAN)</option>
              <option value="JSON">JSON</option>
              <option value="DATE">Date (DATE)</option>
            </select>
          </div>

          {formData.type === 'BOOLEAN' ? (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valeur *
              </label>
              <select
                value={formData.valeur}
                onChange={(e) => setFormData({ ...formData, valeur: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="">Sélectionner...</option>
                <option value="true">Oui (true)</option>
                <option value="false">Non (false)</option>
              </select>
            </div>
          ) : formData.type === 'JSON' ? (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valeur (JSON) *
              </label>
              <textarea
                value={formData.valeur}
                onChange={(e) => setFormData({ ...formData, valeur: e.target.value })}
                rows={5}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono text-sm"
                placeholder='{"key": "value"}'
                required
              />
            </div>
          ) : (
            <Input
              label="Valeur *"
              type={formData.type === 'NUMBER' ? 'number' : formData.type === 'DATE' ? 'date' : 'text'}
              value={formData.valeur}
              onChange={(e) => setFormData({ ...formData, valeur: e.target.value })}
              placeholder={formData.type === 'NUMBER' ? '0' : 'Valeur du paramètre'}
              required
            />
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Description du paramètre..."
            />
          </div>

          <div className="flex justify-end gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={() => {
                setIsModalOpen(false);
                setEditingSetting(null);
              }}
            >
              Annuler
            </Button>
            <Button type="submit">
              {editingSetting ? 'Mettre à jour' : 'Créer'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
