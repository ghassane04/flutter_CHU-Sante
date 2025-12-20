import React, { useState, useEffect } from 'react';
import { Users, Bed, Activity, TrendingUp, BarChart3, PieChart, LineChart } from 'lucide-react';
import { api, DashboardStats, ActesByTypeStats, RevenusByMonthStats, SejoursByServiceStats } from '../services/api';
import { KPICard } from '../components/ui/KPICard';
import { 
  BarChart, 
  Bar, 
  PieChart as RechartsPie, 
  Pie, 
  LineChart as RechartsLine, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer,
  Cell 
} from 'recharts';

// Couleurs pour les graphiques
const COLORS = ['#3B82F6', '#10B981', '#8B5CF6', '#F59E0B', '#EF4444', '#EC4899', '#06B6D4', '#84CC16'];

export function Dashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [actesByType, setActesByType] = useState<ActesByTypeStats[]>([]);
  const [revenusByMonth, setRevenusByMonth] = useState<RevenusByMonthStats[]>([]);
  const [sejoursByService, setSejoursByService] = useState<SejoursByServiceStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      const [statsData, actesData, revenusData, sejoursData] = await Promise.all([
        api.getDashboardStats(),
        api.getActesByType().catch(() => []),
        api.getRevenusByMonth().catch(() => []),
        api.getSejoursByService().catch(() => [])
      ]);
      setStats(statsData);
      setActesByType(actesData);
      setRevenusByMonth(revenusData);
      setSejoursByService(sejoursData);
      setError(null);
    } catch (err) {
      setError('Erreur lors du chargement des statistiques du tableau de bord');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement des statistiques...</p>
        </div>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-lg">
          <p className="font-medium">Erreur</p>
          <p className="text-sm">{error || 'Impossible de charger les données'}</p>
          <button
            onClick={loadDashboardData}
            className="mt-3 px-4 py-2 bg-red-100 hover:bg-red-200 rounded text-sm"
          >
            Réessayer
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Tableau de Bord</h1>
        <button
          onClick={loadDashboardData}
          className="px-4 py-2 text-sm bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg transition"
        >
          Actualiser
        </button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KPICard
          title="Total Patients"
          value={stats.totalPatients}
          icon={Users}
          iconBg="bg-blue-500"
        />
        <KPICard
          title="Séjours en Cours"
          value={stats.sejoursEnCours}
          icon={Bed}
          iconBg="bg-green-500"
        />
        <KPICard
          title="Actes Médicaux"
          value={stats.totalActes}
          icon={Activity}
          iconBg="bg-purple-500"
        />
        <KPICard
          title="Revenus du Mois"
          value={`${stats.revenusMois.toLocaleString('fr-FR')} €`}
          icon={TrendingUp}
          iconBg="bg-orange-500"
          subtitle={`Année: ${stats.revenusAnnee.toLocaleString('fr-FR')} €`}
        />
      </div>

      {/* Informations supplémentaires */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Vue d'ensemble</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Patients enregistrés</span>
              <span className="text-xl font-bold text-blue-600">{stats.totalPatients}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Séjours actifs</span>
              <span className="text-xl font-bold text-green-600">{stats.sejoursEnCours}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Actes réalisés</span>
              <span className="text-xl font-bold text-purple-600">{stats.totalActes}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <TrendingUp className="w-5 h-5 text-orange-600 mr-2" />
            Revenus
          </h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center pb-3 border-b">
              <span className="text-gray-600 text-sm">Total du mois</span>
              <span className="text-2xl font-bold text-orange-600">
                {stats.revenusMois.toLocaleString('fr-FR')} €
              </span>
            </div>
            <div className="flex justify-between items-center pb-3 border-b">
              <span className="text-gray-600 text-sm">Total de l'année</span>
              <span className="text-xl font-bold text-green-600">
                {stats.revenusAnnee.toLocaleString('fr-FR')} €
              </span>
            </div>
            <div className="flex justify-between items-center pb-3 border-b">
              <span className="text-gray-600 text-sm">Revenus totaux</span>
              <span className="text-lg font-semibold text-blue-600">
                {stats.revenusTotal.toLocaleString('fr-FR')} €
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600 text-sm">Moyenne par acte</span>
              <span className="text-lg font-semibold text-gray-900">
                {stats.totalActes > 0
                  ? (stats.revenusMois / stats.totalActes).toFixed(2)
                  : '0'} €
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Graphiques statistiques */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Graphique: Actes par type */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center mb-4">
            <BarChart3 className="w-5 h-5 text-purple-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Actes Médicaux par Type</h3>
          </div>
          {actesByType.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={actesByType}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="type" angle={-45} textAnchor="end" height={80} fontSize={12} />
                <YAxis />
                <Tooltip 
                  formatter={(value: number, name: string) => [
                    name === 'count' ? value : `${value.toLocaleString('fr-FR')} €`,
                    name === 'count' ? 'Nombre' : 'Revenus'
                  ]}
                />
                <Legend />
                <Bar dataKey="count" fill="#8B5CF6" name="Nombre d'actes" />
                <Bar dataKey="revenus" fill="#F59E0B" name="Revenus (€)" />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-64 text-gray-400">
              <p>Aucune donnée disponible</p>
            </div>
          )}
        </div>

        {/* Graphique: Séjours par service */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center mb-4">
            <PieChart className="w-5 h-5 text-green-600 mr-2" />
            <h3 className="text-lg font-semibold text-gray-900">Séjours par Service</h3>
          </div>
          {sejoursByService.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <RechartsPie>
                <Pie
                  data={sejoursByService}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ service, actifs, percent }) => 
                    `${service}: ${actifs} (${(percent * 100).toFixed(0)}%)`
                  }
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="actifs"
                >
                  {sejoursByService.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip 
                  formatter={(value: number) => [`${value} séjours`, 'Actifs']}
                />
              </RechartsPie>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-64 text-gray-400">
              <p>Aucune donnée disponible</p>
            </div>
          )}
        </div>
      </div>

      {/* Graphique: Revenus par mois */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center mb-4">
          <LineChart className="w-5 h-5 text-blue-600 mr-2" />
          <h3 className="text-lg font-semibold text-gray-900">Évolution des Revenus Mensuels</h3>
        </div>
        {revenusByMonth.length > 0 ? (
          <ResponsiveContainer width="100%" height={300}>
            <RechartsLine data={revenusByMonth}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="mois" />
              <YAxis yAxisId="left" />
              <YAxis yAxisId="right" orientation="right" />
              <Tooltip 
                formatter={(value: number, name: string) => [
                  name === 'revenus' ? `${value.toLocaleString('fr-FR')} €` : value,
                  name === 'revenus' ? 'Revenus' : 'Actes'
                ]}
              />
              <Legend />
              <Line 
                yAxisId="left"
                type="monotone" 
                dataKey="revenus" 
                stroke="#3B82F6" 
                strokeWidth={2}
                name="Revenus (€)"
                dot={{ r: 4 }}
              />
              <Line 
                yAxisId="right"
                type="monotone" 
                dataKey="actes" 
                stroke="#10B981" 
                strokeWidth={2}
                name="Nombre d'actes"
                dot={{ r: 4 }}
              />
            </RechartsLine>
          </ResponsiveContainer>
        ) : (
          <div className="flex items-center justify-center h-64 text-gray-400">
            <p>Aucune donnée disponible</p>
          </div>
        )}
      </div>

      {/* Guide de démarrage */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg shadow p-6 border border-blue-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-3">Guide de démarrage rapide</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex items-start space-x-3">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
              1
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Créer des services</h4>
              <p className="text-sm text-gray-600">Ajoutez les différents services hospitaliers</p>
            </div>
          </div>
          <div className="flex items-start space-x-3">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
              2
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Enregistrer des patients</h4>
              <p className="text-sm text-gray-600">Créez les fiches des patients</p>
            </div>
          </div>
          <div className="flex items-start space-x-3">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
              3
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Gérer les séjours</h4>
              <p className="text-sm text-gray-600">Suivez l'admission et la sortie des patients</p>
            </div>
          </div>
          <div className="flex items-start space-x-3">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
              4
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Enregistrer les actes</h4>
              <p className="text-sm text-gray-600">Documentez tous les actes médicaux effectués</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
