import React, { useState, useEffect } from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { Plus, TrendingUp, Calendar, DollarSign, Loader2 } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { investmentService, Investment } from '../services/investmentService';

export function Investments() {
  const [investments, setInvestments] = useState<Investment[]>([]);
  const [stats, setStats] = useState<any>(null);
  const [selectedInvestment, setSelectedInvestment] = useState<Investment | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [investmentsData, statsData] = await Promise.all([
        investmentService.getAll(),
        investmentService.getStats(),
      ]);
      setInvestments(investmentsData);
      setStats(statsData);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des données');
      console.error('Erreur:', err);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (statut: string) => {
    const styles: Record<string, string> = {
      'EN_COURS': 'bg-green-100 text-green-800',
      'PLANIFIE': 'bg-orange-100 text-orange-800',
      'TERMINE': 'bg-blue-100 text-blue-800',
      'ANNULE': 'bg-red-100 text-red-800',
    };
    const labels: Record<string, string> = {
      'EN_COURS': 'En cours',
      'PLANIFIE': 'Planifié',
      'TERMINE': 'Terminé',
      'ANNULE': 'Annulé',
    };
    return (
      <span className={`px-3 py-1 rounded-full text-xs font-medium ${styles[statut] || 'bg-gray-100 text-gray-800'}`}>
        {labels[statut] || statut}
      </span>
    );
  };

  const getCategorieColor = (categorie: string) => {
    const colors: Record<string, string> = {
      'EQUIPEMENT': '#0B6FB0',
      'INFRASTRUCTURE': '#17A2A6',
      'TECHNOLOGIE': '#48BB78',
      'FORMATION': '#F6AD55',
    };
    return colors[categorie] || '#94A3B8';
  };

  const budgetData = React.useMemo(() => {
    const categoryCounts: Record<string, number> = {};
    investments.forEach(inv => {
      categoryCounts[inv.categorie] = (categoryCounts[inv.categorie] || 0) + inv.montant;
    });
    
    return Object.entries(categoryCounts).map(([name, value]) => ({
      name,
      value,
      color: getCategorieColor(name),
    }));
  }, [investments]);

  const totalROI = investments.reduce((sum, inv) => 
    sum + (inv.retourInvestissement ? (inv.montant * inv.retourInvestissement / 100) : 0), 0
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p className="text-red-800">Erreur: {error}</p>
        <Button onClick={loadData} className="mt-2">Réessayer</Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Investissements</h1>
          <p className="text-gray-600">Gestion du portefeuille d'investissements hospitaliers</p>
        </div>
        <Button variant="primary" size="md">
          <Plus className="w-5 h-5 mr-2" />
          Nouvel investissement
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center gap-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <DollarSign className="w-6 h-6 text-[#0B6FB0]" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Budget total investi</p>
              <p className="text-2xl font-bold text-gray-900">
                {stats?.totalInvesti?.toLocaleString('fr-FR') || '0'} €
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
              <p className="text-2xl font-bold text-gray-900">
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
              <p className="text-sm text-gray-600">Projets en cours</p>
              <p className="text-2xl font-bold text-gray-900">
                {investments.filter(i => i.statut === 'EN_COURS').length}
              </p>
            </div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Budget Distribution */}
        {budgetData.length > 0 && (
          <Card>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Répartition du budget</h3>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={budgetData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ percent }) => `${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {budgetData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => `${Number(value).toLocaleString('fr-FR')} €`} />
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
          </Card>
        )}

        {/* Investment List */}
        <div className="lg:col-span-2 space-y-4">
          {investments.length === 0 ? (
            <Card>
              <p className="text-center text-gray-500 py-8">Aucun investissement trouvé</p>
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
                        <p className="font-medium text-green-600">
                          +{investment.retourInvestissement || 0}%
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-500">Catégorie</p>
                        <p className="font-medium text-gray-900">{investment.categorie}</p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-500">Échéance</p>
                        <p className="font-medium text-gray-900">
                          {investment.dateFinPrevue 
                            ? new Date(investment.dateFinPrevue).toLocaleDateString('fr-FR')
                            : '-'}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-col gap-2">
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
            </div>
          }
        >
          <div className="space-y-6">
            <div>
              <h4 className="font-medium text-gray-900 mb-2">Description</h4>
              <p className="text-gray-700">{selectedInvestment.description}</p>
            </div>

            {selectedInvestment.beneficesAttendus && (
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Bénéfices attendus</h4>
                <p className="text-gray-700">{selectedInvestment.beneficesAttendus}</p>
              </div>
            )}

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
                  {selectedInvestment.retourInvestissement && (
                    <div>
                      <p className="text-sm text-gray-600">ROI estimé</p>
                      <p className="text-lg font-semibold text-green-600">
                        +{selectedInvestment.retourInvestissement}% (
                        {(selectedInvestment.montant * selectedInvestment.retourInvestissement / 100).toLocaleString('fr-FR')} €)
                      </p>
                    </div>
                  )}
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
                    <p className="text-sm text-gray-600">Date d'investissement</p>
                    <p className="font-medium text-gray-900">
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
                      <p className="font-medium text-gray-900">
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
    </div>
  );
}
