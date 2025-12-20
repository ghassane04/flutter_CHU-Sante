import React, { useState, useMemo } from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Euro, Users, BedDouble, TrendingUp } from 'lucide-react';
import { KPICard } from './KPICard';
import { sejours, services, calculateSejourCost, calculateStats } from '../data/mockData';

export function Dashboard() {
  const [startDate, setStartDate] = useState('2025-10-01');
  const [endDate, setEndDate] = useState('2025-11-30');
  const [serviceFilter, setServiceFilter] = useState<number | undefined>(undefined);

  // Filtrer les séjours par période
  const filteredSejours = useMemo(() => {
    return sejours.filter(sejour => {
      const entree = new Date(sejour.dateEntree);
      const start = new Date(startDate);
      const end = new Date(endDate);
      return entree >= start && entree <= end;
    });
  }, [startDate, endDate]);

  // Calculer les statistiques
  const stats = useMemo(() => {
    return calculateStats(filteredSejours, serviceFilter);
  }, [filteredSejours, serviceFilter]);

  // Données pour le graphique d'évolution temporelle
  const timelineData = useMemo(() => {
    const dataByWeek: { [key: string]: number } = {};

    filteredSejours.forEach(sejour => {
      if (serviceFilter && sejour.serviceId !== serviceFilter) return;

      const date = new Date(sejour.dateEntree);
      const weekKey = `S${Math.ceil(date.getDate() / 7)} ${date.toLocaleString('fr-FR', { month: 'short' })}`;

      if (!dataByWeek[weekKey]) {
        dataByWeek[weekKey] = 0;
      }
      dataByWeek[weekKey] += calculateSejourCost(sejour);
    });

    return Object.entries(dataByWeek).map(([period, cost]) => ({
      period,
      cout: Math.round(cost),
    }));
  }, [filteredSejours, serviceFilter]);

  // Données pour le graphique par service
  const serviceData = useMemo(() => {
    const dataByService: { [key: number]: number } = {};

    filteredSejours.forEach(sejour => {
      if (!dataByService[sejour.serviceId]) {
        dataByService[sejour.serviceId] = 0;
      }
      dataByService[sejour.serviceId] += calculateSejourCost(sejour);
    });

    return services.map(service => ({
      nom: service.nom,
      cout: Math.round(dataByService[service.id] || 0),
    }));
  }, [filteredSejours]);

  // Calcul de la prévision (moyenne glissante simple)
  const prediction = useMemo(() => {
    if (timelineData.length === 0) return 0;
    const avgWeeklyCost = timelineData.reduce((sum, d) => sum + d.cout, 0) / timelineData.length;
    return Math.round(avgWeeklyCost * 4); // Prévision pour le mois suivant
  }, [timelineData]);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-gray-900 mb-2">Tableau de bord financier</h1>
        <p className="text-gray-600">Vue d'ensemble des coûts hospitaliers et prévisions</p>
      </div>

      {/* Filtres */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 className="text-gray-900 mb-4">Filtres</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm text-gray-700 mb-2">Date de début</label>
            <input
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-700 mb-2">Date de fin</label>
            <input
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-700 mb-2">Service</label>
            <select
              value={serviceFilter || ''}
              onChange={(e) => setServiceFilter(e.target.value ? Number(e.target.value) : undefined)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Tous les services</option>
              {services.map(service => (
                <option key={service.id} value={service.id}>{service.nom}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
        <KPICard
          title="Coût total"
          value={`${stats.totalCost.toLocaleString('fr-FR')} €`}
          icon={Euro}
          color="bg-blue-600"
        />
        <KPICard
          title="Nombre de séjours"
          value={stats.numberOfSejours}
          icon={BedDouble}
          color="bg-green-600"
        />
        <KPICard
          title="Patients"
          value={stats.numberOfPatients}
          icon={Users}
          color="bg-purple-600"
        />
        <KPICard
          title="Coût moyen / séjour"
          value={`${Math.round(stats.avgCostPerSejour).toLocaleString('fr-FR')} €`}
          icon={TrendingUp}
          color="bg-orange-600"
        />
      </div>

      {/* Prévision */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg shadow-md p-6 mb-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-white mb-2">Prévision mois suivant</h2>
            <p className="text-blue-100 text-sm">Basée sur la moyenne glissante des périodes précédentes</p>
          </div>
          <div className="text-right">
            <p className="text-white">{prediction.toLocaleString('fr-FR')} €</p>
            <p className="text-blue-100 text-sm">Coût estimé</p>
          </div>
        </div>
      </div>

      {/* Graphiques */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Évolution temporelle */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-gray-900 mb-4">Évolution des coûts</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={timelineData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="period" />
              <YAxis />
              <Tooltip formatter={(value) => `${value} €`} />
              <Legend />
              <Line type="monotone" dataKey="cout" stroke="#2563eb" strokeWidth={2} name="Coût" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Coûts par service */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-gray-900 mb-4">Coûts par service</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={serviceData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="nom" />
              <YAxis />
              <Tooltip formatter={(value) => `${value} €`} />
              <Legend />
              <Bar dataKey="cout" fill="#2563eb" name="Coût" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
