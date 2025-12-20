import React, { useState, useEffect } from 'react';
import { Users, Settings as SettingsIcon, Loader2, Trash2, Edit, Plus } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Modal } from '../components/ui/Modal';
import { api, User as ApiUser } from '../services/api';

interface FormData {
  username: string;
  email: string;
  password: string;
  nom: string;
  prenom: string;
}

export function Settings() {
  const [activeTab, setActiveTab] = useState<'users' | 'system'>('users');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [users, setUsers] = useState<ApiUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingUser, setEditingUser] = useState<ApiUser | null>(null);
  const [formData, setFormData] = useState<FormData>({
    username: '',
    email: '',
    password: '',
    nom: '',
    prenom: ''
  });

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const data = await api.getUsers();
      setUsers(data);
    } catch (error) {
      console.error('Erreur chargement utilisateurs:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async () => {
    try {
      if (editingUser) {
        await api.updateUser(editingUser.id, {
          email: formData.email,
          nom: formData.nom,
          prenom: formData.prenom
        });
      } else {
        await api.createUser({
          username: formData.username,
          email: formData.email,
          password: formData.password,
          nom: formData.nom,
          prenom: formData.prenom
        });
      }
      setIsModalOpen(false);
      resetForm();
      loadUsers();
    } catch (error) {
      console.error('Erreur sauvegarde utilisateur:', error);
      alert('Erreur lors de la sauvegarde');
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) return;
    try {
      await api.deleteUser(id);
      loadUsers();
    } catch (error) {
      console.error('Erreur suppression:', error);
      alert('Erreur lors de la suppression');
    }
  };

  const openEditModal = (user: ApiUser) => {
    setEditingUser(user);
    setFormData({
      username: user.username,
      email: user.email,
      password: '',
      nom: user.nom || '',
      prenom: user.prenom || ''
    });
    setIsModalOpen(true);
  };

  const resetForm = () => {
    setEditingUser(null);
    setFormData({
      username: '',
      email: '',
      password: '',
      nom: '',
      prenom: ''
    });
  };

  const getStatusBadge = (status: string) => {
    const styles = {
      active: 'bg-green-100 text-green-800',
      inactive: 'bg-gray-100 text-gray-800',
    };
    const labels = {
      active: 'Actif',
      inactive: 'Inactif',
    };
    return (
      <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[status as keyof typeof styles]}`}>
        {labels[status as keyof typeof labels]}
      </span>
    );
  };

  const tabs = [
    { id: 'users', label: 'Utilisateurs', icon: Users },
    { id: 'system', label: 'Système', icon: SettingsIcon },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-gray-900 mb-2">Paramètres</h1>
        <p className="text-gray-600">Configuration et administration du système</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <div className="flex gap-2 overflow-x-auto">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-colors min-h-[48px] whitespace-nowrap ${
                  activeTab === tab.id
                    ? 'border-[#0B6FB0] text-[#0B6FB0]'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <Icon className="w-5 h-5" />
                <span className="font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Users Tab */}
      {activeTab === 'users' && (
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <p className="text-gray-600">Gestion des utilisateurs du système</p>
            <Button variant="primary" size="md" onClick={() => setIsModalOpen(true)}>
              Ajouter un utilisateur
            </Button>
          </div>

          <Card padding="none">
            {loading ? (
              <div className="flex justify-center items-center py-12">
                <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50 border-b border-gray-200">
                    <tr>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Nom d'utilisateur</th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Nom complet</th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Email</th>
                      <th className="px-6 py-4 text-center text-sm font-medium text-gray-700">Statut</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-gray-700">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {users.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                          Aucun utilisateur trouvé
                        </td>
                      </tr>
                    ) : (
                      users.map((user) => (
                        <tr key={user.id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 font-medium text-gray-900">{user.username}</td>
                          <td className="px-6 py-4 text-gray-600">
                            {user.prenom && user.nom ? `${user.prenom} ${user.nom}` : '-'}
                          </td>
                          <td className="px-6 py-4 text-gray-600">{user.email}</td>
                          <td className="px-6 py-4 text-center">
                            {getStatusBadge(user.enabled ? 'active' : 'inactive')}
                          </td>
                          <td className="px-6 py-4 text-right">
                            <div className="flex justify-end gap-2">
                              <Button 
                                variant="ghost" 
                                size="sm" 
                                onClick={() => openEditModal(user)}
                              >
                                <Edit className="w-4 h-4 mr-1" />
                                Modifier
                              </Button>
                              <Button 
                                variant="danger" 
                                size="sm"
                                onClick={() => handleDelete(user.id)}
                              >
                                <Trash2 className="w-4 h-4 mr-1" />
                                Supprimer
                              </Button>
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            )}
          </Card>
        </div>
      )}

      {/* System Tab */}
      {activeTab === 'system' && (
        <div className="space-y-6">
          <Card>
            <h3 className="text-gray-900 mb-4">Configuration générale</h3>
            <div className="space-y-4">
              <Input
                label="Nom de l'établissement"
                defaultValue="CHU Santé"
                placeholder="Nom de l'hôpital"
              />
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Calendrier fiscal</label>
                <select className="input w-full">
                  <option>Janvier - Décembre (Année civile)</option>
                  <option>Avril - Mars</option>
                  <option>Juillet - Juin</option>
                </select>
              </div>
              <Input
                label="Devise par défaut"
                defaultValue="EUR (€)"
                disabled
              />
            </div>
          </Card>

          <Card>
            <h3 className="text-gray-900 mb-4">Seuils d'alerte</h3>
            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Input
                  label="Alerte budget (% dépassement)"
                  type="number"
                  defaultValue="85"
                  helperText="Déclencher une alerte à ce % d'utilisation"
                />
                <Input
                  label="Alerte critique (%)"
                  type="number"
                  defaultValue="95"
                  helperText="Seuil d'alerte critique"
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Input
                  label="Variation anormale (%)"
                  type="number"
                  defaultValue="25"
                  helperText="Détecter les variations > à ce %"
                />
                <Input
                  label="Montant minimum alerte (€)"
                  type="number"
                  defaultValue="1000"
                  helperText="Ne pas alerter en dessous de ce montant"
                />
              </div>
            </div>
            <div className="mt-6 flex justify-end">
              <Button variant="primary" size="md">
                Enregistrer les modifications
              </Button>
            </div>
          </Card>
        </div>
      )}

      {/* User Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          resetForm();
        }}
        title={editingUser ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur'}
        footer={
          <div className="flex gap-3">
            <Button variant="ghost" onClick={() => {
              setIsModalOpen(false);
              resetForm();
            }} fullWidth>
              Annuler
            </Button>
            <Button variant="primary" onClick={handleSubmit} fullWidth>
              {editingUser ? 'Modifier' : 'Créer'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          {!editingUser && (
            <Input
              label="Nom d'utilisateur"
              value={formData.username}
              onChange={(e) => setFormData({...formData, username: e.target.value})}
              placeholder="jdupont"
              required
            />
          )}
          <Input
            label="Prénom"
            value={formData.prenom}
            onChange={(e) => setFormData({...formData, prenom: e.target.value})}
            placeholder="Jean"
          />
          <Input
            label="Nom"
            value={formData.nom}
            onChange={(e) => setFormData({...formData, nom: e.target.value})}
            placeholder="Dupont"
          />
          <Input
            label="Email"
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({...formData, email: e.target.value})}
            placeholder="jean.dupont@chu-sante.fr"
            required
          />
          {!editingUser && (
            <Input
              label="Mot de passe"
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
              placeholder="••••••••"
              helperText="Minimum 6 caractères"
              required
            />
          )}
        </div>
      </Modal>
    </div>
  );
}