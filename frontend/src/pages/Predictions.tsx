import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { TrendingUp, Download, RefreshCw, AlertCircle, Loader2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import axios from 'axios';

const API_URL = 'http://localhost:8085/api';

interface PredictionPoint {
  date: string;
  valeur: number;
  min: number;
  max: number;
}

const getUnitLabel = (type: string): string => {
  switch(type) {
    case 'COUT': return '€';
    case 'PATIENTS': return 'patients';
    case 'OCCUPATION': return '%';
    default: return '';
  }
};

const formatValue = (value: number, type: string): string => {
  switch(type) {
    case 'COUT':
      return `${value.toLocaleString('fr-FR')} €`;
    case 'PATIENTS':
      return `${Math.round(value)} patients`;
    case 'OCCUPATION':
      return `${value.toFixed(1)} %`;
    default:
      return value.toString();
  }
};

interface ServicePrediction {
  service: string;
  predictionType: string;
  predictions: PredictionPoint[];
  confiance: number;
  tendance: string;
  valeurMoyenne: number;
  valeurMin: number;
  valeurMax: number;
  facteursCles: string[];
  recommandations: string[];
}

export function Predictions() {
  const [period, setPeriod] = useState('month');
  const [selectedService, setSelectedService] = useState('Urgences');
  const [predictionType, setPredictionType] = useState('COUT');
  const [horizon, setHorizon] = useState('30');
  const [showFilters, setShowFilters] = useState(false);
  const [loading, setLoading] = useState(false);
  const [predictionData, setPredictionData] = useState<ServicePrediction | null>(null);
  const [allServicesPredictions, setAllServicesPredictions] = useState<ServicePrediction[]>([]);
  const [currentStats, setCurrentStats] = useState<any[]>([]);

  useEffect(() => {
    loadPredictions();
    loadAllServicesPredictions();
    loadCurrentStatistics();
  }, [selectedService, horizon, predictionType]);

  const loadPredictions = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(
        `${API_URL}/ml/predictions/service/${selectedService}?daysAhead=${horizon}&predictionType=${predictionType}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setPredictionData(response.data);
    } catch (error) {
      console.error('Erreur chargement prédictions:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadAllServicesPredictions = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(
        `${API_URL}/ml/predictions/all-services?daysAhead=${horizon}&predictionType=${predictionType}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setAllServicesPredictions(response.data);
    } catch (error) {
      console.error('Erreur chargement prédictions services:', error);
    }
  };

  const loadCurrentStatistics = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(
        `${API_URL}/ml/statistics/current?type=${predictionType}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setCurrentStats(response.data);
    } catch (error) {
      console.error('Erreur chargement statistiques:', error);
    }
  };

  const handleRefresh = () => {
    loadPredictions();
    loadAllServicesPredictions();
    loadCurrentStatistics();
  };

  const handleDownload = () => {
    if (!predictionData) return;
    
    // Créer le contenu CSV
    const headers = ['Date', 'Valeur', 'Min', 'Max', 'Unité'];
    const unit = getUnitLabel(predictionType);
    const rows = predictionData.predictions.map(p => [
      new Date(p.date).toLocaleDateString('fr-FR'),
      p.valeur.toString(),
      p.min.toString(),
      p.max.toString(),
      unit
    ]);
    
    const csvContent = [
      headers.join(';'),
      ...rows.map(row => row.join(';'))
    ].join('\n');
    
    // Créer le fichier et déclencher le téléchargement
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `predictions_${selectedService}_${predictionType}_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const formatChartData = () => {
    if (!predictionData) return [];
    
    // Format date selon l'horizon
    const formatDate = (dateStr: string, idx: number) => {
      const date = new Date(dateStr);
      const days = parseInt(horizon);
      
      if (days <= 30) {
        // Mois: afficher jour + mois court
        return date.toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' });
      } else if (days <= 180) {
        // Semestre: afficher semaine ou jour si important
        if (idx % 7 === 0) { // Une semaine sur 7
          return date.toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' });
        }
        return '';
      } else {
        // Année: afficher mois
        if (idx % 30 === 0) { // Un mois
          return date.toLocaleDateString('fr-FR', { month: 'short', year: '2-digit' });
        }
        return '';
      }
    };
    
    return predictionData.predictions.map((p, idx) => ({
      date: formatDate(p.date, idx),
      fullDate: new Date(p.date).toLocaleDateString('fr-FR'),
      valeur: p.valeur,
      min: p.min,
      max: p.max,
    }));
  };

  const getRiskLevel = (tendance: string, variation: number): string => {
    if (tendance === 'HAUSSE' && variation > 10) return 'high';
    if (tendance === 'HAUSSE' && variation > 5) return 'medium';
    if (tendance === 'BAISSE' && variation < -5) return 'medium';
    return 'low';
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
        {labels[risk as keyof typeof labels]}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
        <div>
          <h1 className="text-gray-900 mb-2">Prédictions financières</h1>
          <p className="text-gray-600">Anticipation des dépenses et analyse prédictive</p>
        </div>
        <div className="flex flex-wrap gap-3">
          <Button variant="secondary" size="md" onClick={handleRefresh} disabled={loading}>
            {loading ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <RefreshCw className="w-4 h-4 mr-2" />}
            Régénérer
          </Button>
          <Button variant="ghost" size="md" onClick={handleDownload} disabled={!predictionData}>
            <Download className="w-4 h-4 mr-2" />
            Télécharger
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-gray-900">Filtres</h3>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="md:hidden text-sm text-[#0B6FB0] font-medium"
          >
            {showFilters ? 'Masquer' : 'Afficher'}
          </button>
        </div>
        <div className={`grid grid-cols-1 md:grid-cols-3 gap-4 ${showFilters ? 'block' : 'hidden md:grid'}`}>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Service</label>
            <select
              value={selectedService}
              onChange={(e) => setSelectedService(e.target.value)}
              className="input w-full"
            >
              <option value="Urgences">Urgences</option>
              <option value="Chirurgie">Chirurgie</option>
              <option value="Cardiologie">Cardiologie</option>
              <option value="Pediatrie">Pédiatrie</option>
              <option value="Maternite">Maternité</option>
              <option value="Radiologie">Radiologie</option>
              <option value="Oncologie">Oncologie</option>
              <option value="Neurologie">Neurologie</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Type de prédiction</label>
            <select 
              value={predictionType}
              onChange={(e) => setPredictionType(e.target.value)}
              className="input w-full"
            >
              <option value="COUT">Coûts (€)</option>
              <option value="PATIENTS">Nombre de patients</option>
              <option value="OCCUPATION">Taux d'occupation (%)</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Horizon de prévision</label>
            <select
              value={horizon}
              onChange={(e) => setHorizon(e.target.value)}
              className="input w-full"
            >
              <option value="30">1 mois (30 jours)</option>
              <option value="90">3 mois (90 jours)</option>
              <option value="180">6 mois (180 jours)</option>
              <option value="365">1 an (365 jours)</option>
            </select>
          </div>
        </div>
      </Card>

      {/* Current Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {currentStats.length > 0 && (
          <>
            <Card>
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm font-medium text-gray-600">
                  {predictionType === 'PATIENTS' ? 'Patients Actuels' : 
                   predictionType === 'COUT' ? 'Coût Moyen Actuel' : 
                   'Occupation Actuelle'}
                </h4>
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              </div>
              <p className="text-3xl font-bold text-gray-900">
                {predictionType === 'PATIENTS' ? 
                  currentStats.find(s => s.service === selectedService)?.total || 0 :
                 predictionType === 'COUT' ? 
                  (currentStats.find(s => s.service === selectedService)?.cout_moyen || 0).toLocaleString('fr-FR') + ' €' :
                  (currentStats.find(s => s.service === selectedService)?.taux || 0).toFixed(1) + '%'}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                {selectedService} - Données en temps réel
              </p>
            </Card>
            
            <Card>
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm font-medium text-gray-600">Total Tous Services</h4>
                <AlertCircle className="w-4 h-4 text-blue-500" />
              </div>
              <p className="text-3xl font-bold text-gray-900">
                {predictionType === 'PATIENTS' ? 
                  currentStats.reduce((sum, s) => sum + (s.total || 0), 0) :
                 predictionType === 'COUT' ? 
                  (currentStats.reduce((sum, s) => sum + (s.cout_moyen || 0), 0) / currentStats.length).toLocaleString('fr-FR') + ' €' :
                  (currentStats.reduce((sum, s) => sum + (s.taux || 0), 0) / currentStats.length).toFixed(1) + '%'}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                {predictionType === 'PATIENTS' ? 'patients' : predictionType === 'COUT' ? 'moyenne' : 'moyenne'} dans l'hôpital
              </p>
            </Card>
            
            <Card>
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-sm font-medium text-gray-600">Évolution Prévue</h4>
                <TrendingUp className={`w-4 h-4 ${
                  predictionData?.tendance === 'HAUSSE' ? 'text-red-500' :
                  predictionData?.tendance === 'BAISSE' ? 'text-green-500' :
                  'text-gray-500'
                }`} />
              </div>
              <p className="text-3xl font-bold text-gray-900">
                {predictionData?.tendance || 'STABLE'}
              </p>
              <p className="text-sm text-gray-500 mt-1">
                Prochains {horizon} jours
              </p>
            </Card>
          </>
        )}
      </div>

      {/* Main Prediction Card */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          {loading ? (
            <div className="flex items-center justify-center h-96">
              <Loader2 className="w-8 h-8 animate-spin text-[#0B6FB0]" />
            </div>
          ) : predictionData ? (
            <>
              <div className="mb-6">
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h3 className="text-gray-900 mb-1">
                      {predictionType === 'COUT' ? 'Coût estimé' : 
                       predictionType === 'PATIENTS' ? 'Nombre de patients' : 
                       'Taux d\'occupation'} - {selectedService}
                    </h3>
                    <p className="text-sm text-gray-600">Prochains {horizon} jours</p>
                  </div>
                  <div className={`flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    predictionData.confiance >= 90 ? 'bg-green-100 text-green-800' :
                    predictionData.confiance >= 80 ? 'bg-blue-100 text-blue-800' :
                    'bg-orange-100 text-orange-800'
                  }`}>
                    <div className={`w-2 h-2 rounded-full ${
                      predictionData.confiance >= 90 ? 'bg-green-500' :
                      predictionData.confiance >= 80 ? 'bg-blue-500' :
                      'bg-orange-500'
                    }`}></div>
                    Confiance {predictionData.confiance.toFixed(1)}%
                  </div>
                </div>
                <div className="flex items-baseline gap-3">
                  <p className="text-4xl font-bold text-gray-900">
                    {predictionType === 'COUT' ? predictionData.valeurMoyenne.toLocaleString('fr-FR') : 
                     predictionType === 'PATIENTS' ? Math.round(predictionData.valeurMoyenne).toLocaleString('fr-FR') : 
                     predictionData.valeurMoyenne.toFixed(1)} {getUnitLabel(predictionType)}
                  </p>
                  <span className={`font-medium ${
                    predictionData.tendance === 'HAUSSE' ? 'text-red-600' :
                    predictionData.tendance === 'BAISSE' ? 'text-green-600' :
                    'text-gray-600'
                  }`}>
                    {predictionData.tendance === 'HAUSSE' ? '↑' :
                     predictionData.tendance === 'BAISSE' ? '↓' : '→'} {predictionData.tendance}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mt-2">
                  Intervalle: {formatValue(predictionData.valeurMin, predictionType)} - {formatValue(predictionData.valeurMax, predictionType)}
                </p>
              </div>

              <ResponsiveContainer width="100%" height={350}>
                <AreaChart data={formatChartData()}>
                  <defs>
                    <linearGradient id="colorPredicted" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#17A2A6" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#17A2A6" stopOpacity={0}/>
                    </linearGradient>
                    <linearGradient id="colorInterval" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#93C5FD" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#93C5FD" stopOpacity={0.1}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E2E8F0" vertical={false} />
                  <XAxis 
                    dataKey="date" 
                    stroke="#718096" 
                    style={{ fontSize: '12px' }}
                    tick={{ fill: '#718096' }}
                  />
                  <YAxis 
                    stroke="#718096" 
                    style={{ fontSize: '12px' }}
                    tick={{ fill: '#718096' }}
                    tickFormatter={(value) => {
                      if (predictionType === 'COUT') return `${(value/1000).toFixed(0)}k`;
                      if (predictionType === 'PATIENTS') return Math.round(value).toString();
                      return `${value.toFixed(0)}%`;
                    }}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      backgroundColor: 'white', 
                      border: '1px solid #E2E8F0',
                      borderRadius: '8px',
                      fontSize: '14px',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                    }}
                    formatter={(value: any, name: string) => {
                      const formattedValue = formatValue(Number(value), predictionType);
                      const label = name === 'valeur' ? 'Prévision' : 
                                   name === 'min' ? 'Minimum' : 'Maximum';
                      return [formattedValue, label];
                    }}
                    labelFormatter={(label) => `Date: ${label}`}
                  />
                  <Legend 
                    wrapperStyle={{ fontSize: '14px', paddingTop: '20px' }}
                    iconType="line"
                  />
                  {/* Zone d'intervalle de confiance */}
                  <Area
                    type="monotone"
                    dataKey="max"
                    stroke="none"
                    fill="url(#colorInterval)"
                    fillOpacity={1}
                    name="Intervalle de confiance"
                  />
                  <Area
                    type="monotone"
                    dataKey="min"
                    stroke="none"
                    fill="white"
                    name=""
                  />
                  {/* Ligne de prédiction principale */}
                  <Line 
                    type="monotone" 
                    dataKey="valeur" 
                    stroke="#17A2A6" 
                    strokeWidth={3} 
                    name="Prévision"
                    dot={(props: any) => {
                      const { cx, cy, index } = props;
                      // Afficher un point tous les 5 jours pour plus de clarté
                      if (index % 5 === 0) {
                        return <circle cx={cx} cy={cy} r={4} fill="#17A2A6" stroke="white" strokeWidth={2} />;
                      }
                      return null;
                    }}
                    activeDot={{ r: 6, fill: '#17A2A6', stroke: 'white', strokeWidth: 2 }}
                  />
                </AreaChart>
              </ResponsiveContainer>
              
              {/* Légende explicative */}
              <div className="mt-4 p-3 bg-blue-50 rounded-lg">
                <p className="text-sm text-gray-700">
                  <strong>Note:</strong> Les prédictions sont basées sur {predictionData.predictions.length} jours de données. 
                  La zone bleue représente l'intervalle de confiance ({(100 - predictionData.confiance).toFixed(1)}% de marge d'erreur).
                  {predictionType === 'PATIENTS' && ' Les valeurs sont calculées d\'après vos patients actuels et leur évolution historique.'}
                </p>
              </div>
            </>
          ) : (
            <div className="flex items-center justify-center h-96">
              <p className="text-gray-500">Aucune donnée disponible</p>
            </div>
          )}
        </Card>

        <Card>
          <h3 className="text-gray-900 mb-4">Facteurs d'influence</h3>
          {predictionData && predictionData.facteursCles ? (
            <div className="space-y-3">
              {predictionData.facteursCles.map((facteur, idx) => (
                <div key={idx} className="p-3 bg-blue-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <TrendingUp className="w-4 h-4 text-blue-600" />
                    <p className="text-sm font-medium text-gray-900">{facteur}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500">Chargement des facteurs...</p>
          )}

          <div className="mt-6 pt-6 border-t border-gray-200">
            <h4 className="text-gray-900 font-medium mb-3">Recommandations</h4>
            {predictionData && predictionData.recommandations ? (
              <ul className="space-y-2">
                {predictionData.recommandations.map((reco, idx) => (
                  <li key={idx} className="flex items-start gap-2 text-sm text-gray-700">
                    <span className="text-[#17A2A6] mt-1">•</span>
                    <span>{reco}</span>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-sm text-gray-500">Aucune recommandation disponible</p>
            )}
          </div>
        </Card>
      </div>

      {/* Service Predictions Table */}
      <Card>
        <h3 className="text-gray-900 mb-4">Prévisions par service</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-4 text-left text-sm font-medium text-gray-700">Service</th>
                <th className="px-6 py-4 text-right text-sm font-medium text-gray-700">
                  {predictionType === 'COUT' ? 'Coût Moyen' : 
                   predictionType === 'PATIENTS' ? 'Patients Moyen' : 
                   'Occupation Moyenne'}
                </th>
                <th className="px-6 py-4 text-right text-sm font-medium text-gray-700">Min - Max</th>
                <th className="px-6 py-4 text-center text-sm font-medium text-gray-700">Tendance</th>
                <th className="px-6 py-4 text-center text-sm font-medium text-gray-700">Confiance</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {allServicesPredictions.map((pred, index) => {
                const variation = ((pred.valeurMax - pred.valeurMin) / pred.valeurMin * 100);
                const risk = getRiskLevel(pred.tendance, variation);
                return (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-medium text-gray-900">{pred.service}</td>
                    <td className="px-6 py-4 text-right text-gray-600">
                      {formatValue(pred.valeurMoyenne, predictionType)}
                    </td>
                    <td className="px-6 py-4 text-right text-sm text-gray-600">
                      {formatValue(pred.valeurMin, predictionType)} - {formatValue(pred.valeurMax, predictionType)}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        pred.tendance === 'HAUSSE' ? 'bg-red-100 text-red-800' :
                        pred.tendance === 'BAISSE' ? 'bg-green-100 text-green-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {pred.tendance}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center text-sm text-gray-600">
                      {pred.confiance.toFixed(1)}%
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
