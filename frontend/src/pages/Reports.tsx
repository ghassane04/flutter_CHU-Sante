import React, { useState, useEffect, useRef } from 'react';
import { FileText, Download, Eye, Filter, Trash2, Plus } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { api, Report } from '../services/api';
import jsPDF from 'jspdf';

const Reports: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [formData, setFormData] = useState({
    titre: '',
    type: 'COUTS',
    periode: '',
    dateDebut: '',
    dateFin: '',
    resume: ''
  });
  
  const [selectedType, setSelectedType] = useState<string>('all');
  const [selectedPeriod, setSelectedPeriod] = useState<string>('all');
  const [selectedStatut, setSelectedStatut] = useState<string>('all');
  
  const previewRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadReports();
  }, []);

  const loadReports = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await api.getReports();
      setReports(data);
    } catch (err: any) {
      setError(err.message || 'Erreur lors du chargement des rapports');
      console.error('Erreur:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      // Validation: la date de fin doit être après la date de début
      if (new Date(formData.dateFin) <= new Date(formData.dateDebut)) {
        setError('La date de fin doit être postérieure à la date de début');
        return;
      }

      // Convertir les dates au format DateTime pour le backend (ISO 8601 avec heure)
      const reportData = {
        ...formData,
        dateDebut: `${formData.dateDebut}T00:00:00`,
        dateFin: `${formData.dateFin}T23:59:59`,
        generePar: 'admin',
        statut: 'BROUILLON' as const
      };
      await api.createReport(reportData);
      setIsModalOpen(false);
      setFormData({ titre: '', type: 'COUTS', periode: '', dateDebut: '', dateFin: '', resume: '' });
      await loadReports();
    } catch (err: any) {
      setError(err.message || 'Erreur lors de la création du rapport');
    }
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce rapport ?')) {
      try {
        await api.deleteReport(id);
        await loadReports();
      } catch (err: any) {
        setError(err.message || 'Erreur lors de la suppression du rapport');
      }
    }
  };

  const generatePDF = async (report: Report) => {
    try {
      const pdf = new jsPDF('p', 'mm', 'a4');
      const pageWidth = pdf.internal.pageSize.getWidth();
      const pageHeight = pdf.internal.pageSize.getHeight();
      let yPos = 20;

      // Header avec logo/titre
      pdf.setFillColor(37, 99, 235);
      pdf.rect(0, 0, pageWidth, 40, 'F');
      
      pdf.setTextColor(255, 255, 255);
      pdf.setFontSize(24);
      pdf.setFont('helvetica', 'bold');
      pdf.text('Financial Dashboard', pageWidth / 2, 20, { align: 'center' });
      
      pdf.setFontSize(12);
      pdf.setFont('helvetica', 'normal');
      pdf.text('Rapport Hospitalier', pageWidth / 2, 30, { align: 'center' });

      yPos = 55;

      // Titre du rapport
      pdf.setTextColor(0, 0, 0);
      pdf.setFontSize(18);
      pdf.setFont('helvetica', 'bold');
      pdf.text(report.titre, 20, yPos);
      yPos += 10;

      // Ligne de séparation
      pdf.setDrawColor(200, 200, 200);
      pdf.line(20, yPos, pageWidth - 20, yPos);
      yPos += 10;

      // Informations générales
      pdf.setFontSize(11);
      pdf.setFont('helvetica', 'normal');
      pdf.setTextColor(80, 80, 80);
      
      const infos = [
        { label: 'Type', value: getTypeLabel(report.type) },
        { label: 'Période', value: report.periode },
        { label: 'Date début', value: new Date(report.dateDebut).toLocaleDateString('fr-FR') },
        { label: 'Date fin', value: new Date(report.dateFin).toLocaleDateString('fr-FR') },
        { label: 'Statut', value: getStatutLabel(report.statut) }
      ];

      infos.forEach(info => {
        pdf.setFont('helvetica', 'bold');
        pdf.text(`${info.label}:`, 20, yPos);
        pdf.setFont('helvetica', 'normal');
        pdf.text(info.value, 70, yPos);
        yPos += 7;
      });

      yPos += 10;

      // Résumé
      if (report.resume) {
        pdf.setFontSize(12);
        pdf.setFont('helvetica', 'bold');
        pdf.setTextColor(0, 0, 0);
        pdf.text('Résumé', 20, yPos);
        yPos += 8;

        pdf.setFontSize(10);
        pdf.setFont('helvetica', 'normal');
        pdf.setTextColor(60, 60, 60);
        const lines = pdf.splitTextToSize(report.resume, pageWidth - 40);
        pdf.text(lines, 20, yPos);
        yPos += lines.length * 5 + 10;
      }

      // Contenu du rapport
      pdf.setFontSize(12);
      pdf.setFont('helvetica', 'bold');
      pdf.setTextColor(0, 0, 0);
      pdf.text('Contenu du Rapport', 20, yPos);
      yPos += 8;

      // Données selon le type
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'normal');
      
      if (report.type === 'COUTS') {
        // Tableau des coûts
        const tableData = [
          ['Service', 'Budget Alloué', 'Dépenses', 'Écart'],
          ['Cardiologie', '250 000 €', '248 500 €', '-1 500 €'],
          ['Urgences', '180 000 €', '185 200 €', '+5 200 €'],
          ['Pédiatrie', '150 000 €', '142 800 €', '-7 200 €'],
          ['Chirurgie', '320 000 €', '315 600 €', '-4 400 €']
        ];

        drawTable(pdf, tableData, 20, yPos, pageWidth - 40);
        yPos += (tableData.length * 8) + 15;

        // Résumé financier
        pdf.setFontSize(11);
        pdf.setFont('helvetica', 'bold');
        pdf.text('Résumé Financier', 20, yPos);
        yPos += 8;
        
        pdf.setFont('helvetica', 'normal');
        pdf.setFontSize(10);
        pdf.text('Budget Total: 900 000 €', 25, yPos);
        yPos += 6;
        pdf.text('Dépenses Totales: 892 100 €', 25, yPos);
        yPos += 6;
        pdf.setTextColor(0, 150, 0);
        pdf.text('Économies: 7 900 € (0.88%)', 25, yPos);
        yPos += 10;

      } else if (report.type === 'PREDICTIONS') {
        // Prédictions
        pdf.setTextColor(60, 60, 60);
        const predictions = [
          'Augmentation prévue des coûts de 3.2% au Q2 2024',
          'Optimisation possible de 15 000 € sur les achats pharmaceutiques',
          'Nécessité de renforcer l\'équipe d\'urgence (+2 postes)',
          'Budget recommandé pour 2024: 4.2M € (+5% vs 2023)'
        ];

        predictions.forEach(pred => {
          pdf.text('• ' + pred, 25, yPos);
          yPos += 7;
        });
        yPos += 10;

      } else if (report.type === 'ANOMALIES') {
        // Anomalies détectées
        const anomalies = [
          { type: 'CRITIQUE', desc: 'Dépassement budgétaire de 12% en Urgences', impact: 'Élevé' },
          { type: 'ATTENTION', desc: 'Consommation anormale de matériel médical', impact: 'Moyen' },
          { type: 'INFO', desc: 'Variation saisonnière normale détectée', impact: 'Faible' }
        ];

        anomalies.forEach(anomaly => {
          pdf.setFont('helvetica', 'bold');
          pdf.setTextColor(anomaly.type === 'CRITIQUE' ? 200 : anomaly.type === 'ATTENTION' ? 200 : 100, 
                           anomaly.type === 'CRITIQUE' ? 0 : anomaly.type === 'ATTENTION' ? 100 : 100, 
                           0);
          pdf.text(`[${anomaly.type}]`, 25, yPos);
          
          pdf.setFont('helvetica', 'normal');
          pdf.setTextColor(60, 60, 60);
          pdf.text(anomaly.desc, 55, yPos);
          yPos += 6;
          pdf.setFontSize(9);
          pdf.text(`Impact: ${anomaly.impact}`, 55, yPos);
          pdf.setFontSize(10);
          yPos += 8;
        });
      }

      // Footer
      const footerY = pageHeight - 20;
      pdf.setDrawColor(200, 200, 200);
      pdf.line(20, footerY - 5, pageWidth - 20, footerY - 5);
      
      pdf.setFontSize(9);
      pdf.setTextColor(120, 120, 120);
      pdf.setFont('helvetica', 'italic');
      pdf.text('Généré automatiquement par Financial Dashboard', pageWidth / 2, footerY, { align: 'center' });
      pdf.text(`Page 1 - ${new Date().toLocaleDateString('fr-FR')}`, pageWidth - 20, footerY, { align: 'right' });

      return pdf;
    } catch (error) {
      console.error('Erreur lors de la génération du PDF:', error);
      throw error;
    }
  };

  const drawTable = (pdf: jsPDF, data: string[][], x: number, y: number, width: number) => {
    const colWidth = width / data[0].length;
    const rowHeight = 8;

    data.forEach((row, rowIndex) => {
      row.forEach((cell, colIndex) => {
        const cellX = x + (colIndex * colWidth);
        const cellY = y + (rowIndex * rowHeight);

        // Header background
        if (rowIndex === 0) {
          pdf.setFillColor(37, 99, 235);
          pdf.rect(cellX, cellY - 5, colWidth, rowHeight, 'F');
          pdf.setTextColor(255, 255, 255);
          pdf.setFont('helvetica', 'bold');
        } else {
          // Alternating row colors
          if (rowIndex % 2 === 0) {
            pdf.setFillColor(245, 245, 245);
            pdf.rect(cellX, cellY - 5, colWidth, rowHeight, 'F');
          }
          pdf.setTextColor(0, 0, 0);
          pdf.setFont('helvetica', 'normal');
        }

        pdf.text(cell, cellX + 2, cellY);
      });
    });

    // Table borders
    pdf.setDrawColor(200, 200, 200);
    for (let i = 0; i <= data.length; i++) {
      pdf.line(x, y + (i * rowHeight) - 5, x + width, y + (i * rowHeight) - 5);
    }
    for (let i = 0; i <= data[0].length; i++) {
      pdf.line(x + (i * colWidth), y - 5, x + (i * colWidth), y + (data.length * rowHeight) - 5);
    }
  };

  const handleDownload = async (report: Report) => {
    try {
      const pdf = await generatePDF(report);
      pdf.save(`${report.titre.replace(/\s+/g, '_')}_${new Date().toISOString().split('T')[0]}.pdf`);
    } catch (error) {
      console.error('Erreur téléchargement:', error);
      setError('Erreur lors du téléchargement du PDF');
    }
  };

  const handlePreview = (report: Report) => {
    setSelectedReport(report);
    setIsPreviewOpen(true);
  };

  const getTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      COUTS: 'Coûts',
      PREDICTIONS: 'Prédictions',
      ANOMALIES: 'Anomalies',
      PERSONNALISE: 'Personnalisé'
    };
    return labels[type] || type;
  };

  const getStatutLabel = (statut: string) => {
    const labels: Record<string, string> = {
      BROUILLON: 'Brouillon',
      PUBLIE: 'Publié',
      ARCHIVE: 'Archivé'
    };
    return labels[statut] || statut;
  };

  const getTypeBadge = (type: string) => {
    const badges: Record<string, string> = {
      COUTS: 'bg-blue-100 text-blue-800',
      PREDICTIONS: 'bg-purple-100 text-purple-800',
      ANOMALIES: 'bg-red-100 text-red-800',
      PERSONNALISE: 'bg-gray-100 text-gray-800'
    };
    return badges[type] || 'bg-gray-100 text-gray-800';
  };

  const getStatusBadge = (status: string) => {
    const badges: Record<string, string> = {
      BROUILLON: 'bg-gray-100 text-gray-800',
      PUBLIE: 'bg-green-100 text-green-800',
      ARCHIVE: 'bg-yellow-100 text-yellow-800'
    };
    return badges[status] || 'bg-gray-100 text-gray-800';
  };

  const filteredReports = reports.filter(report => {
    const typeMatch = selectedType === 'all' || report.type === selectedType;
    const statutMatch = selectedStatut === 'all' || report.statut === selectedStatut;
    
    let periodMatch = true;
    if (selectedPeriod !== 'all') {
      const now = new Date();
      const reportDate = new Date(report.dateDebut);
      
      switch (selectedPeriod) {
        case 'current':
          periodMatch = reportDate.getMonth() === now.getMonth() && reportDate.getFullYear() === now.getFullYear();
          break;
        case 'last-month':
          const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1);
          periodMatch = reportDate.getMonth() === lastMonth.getMonth() && reportDate.getFullYear() === lastMonth.getFullYear();
          break;
        case 'quarter':
          const currentQuarter = Math.floor(now.getMonth() / 3);
          const reportQuarter = Math.floor(reportDate.getMonth() / 3);
          periodMatch = currentQuarter === reportQuarter && reportDate.getFullYear() === now.getFullYear();
          break;
        case 'year':
          periodMatch = reportDate.getFullYear() === now.getFullYear();
          break;
      }
    }
    
    return typeMatch && periodMatch && statutMatch;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement des rapports...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Rapports</h1>
        <Button onClick={() => setIsModalOpen(true)}>
          <Plus className="w-4 h-4 mr-2" />
          Nouveau rapport
        </Button>
      </div>

      {error && (
        <div className="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Filters */}
      <Card className="mb-6">
        <div className="flex items-center gap-4">
          <Filter className="w-5 h-5 text-gray-400" />
          <div className="flex gap-4 flex-1 flex-wrap">
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Tous les types</option>
              <option value="COUTS">Coûts</option>
              <option value="PREDICTIONS">Prédictions</option>
              <option value="ANOMALIES">Anomalies</option>
              <option value="PERSONNALISE">Personnalisé</option>
            </select>
            
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Toutes les périodes</option>
              <option value="current">Mois en cours</option>
              <option value="last-month">Mois dernier</option>
              <option value="quarter">Trimestre en cours</option>
              <option value="year">Année en cours</option>
            </select>

            <select
              value={selectedStatut}
              onChange={(e) => setSelectedStatut(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Tous les statuts</option>
              <option value="BROUILLON">Brouillon</option>
              <option value="PUBLIE">Publié</option>
              <option value="ARCHIVE">Archivé</option>
            </select>
          </div>
        </div>
      </Card>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <div className="text-sm text-gray-600">Total</div>
          <div className="text-2xl font-bold text-gray-900">{reports.length}</div>
        </Card>
        <Card>
          <div className="text-sm text-gray-600">Brouillons</div>
          <div className="text-2xl font-bold text-gray-600">
            {reports.filter(r => r.statut === 'BROUILLON').length}
          </div>
        </Card>
        <Card>
          <div className="text-sm text-gray-600">Publiés</div>
          <div className="text-2xl font-bold text-green-600">
            {reports.filter(r => r.statut === 'PUBLIE').length}
          </div>
        </Card>
        <Card>
          <div className="text-sm text-gray-600">Filtrés</div>
          <div className="text-2xl font-bold text-blue-600">{filteredReports.length}</div>
        </Card>
      </div>

      {/* Reports Grid */}
      {filteredReports.length === 0 ? (
        <Card>
          <div className="text-center py-12">
            <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">Aucun rapport trouvé</p>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 gap-4">
          {filteredReports.map((report) => (
            <Card key={report.id} className="hover:shadow-lg transition-all duration-300">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-blue-50 rounded-lg">
                    <FileText className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">{report.titre}</h3>
                    <div className="flex gap-2 mt-1">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getTypeBadge(report.type)}`}>
                        {getTypeLabel(report.type)}
                      </span>
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusBadge(report.statut)}`}>
                        {getStatutLabel(report.statut)}
                      </span>
                    </div>
                    <p className="text-sm text-gray-500 mt-1">
                      {report.periode} • {new Date(report.dateDebut).toLocaleDateString('fr-FR')} - {new Date(report.dateFin).toLocaleDateString('fr-FR')}
                    </p>
                  </div>
                </div>
                
                <div className="flex gap-2">
                  <Button 
                    variant="secondary" 
                    size="sm"
                    onClick={() => handlePreview(report)}
                  >
                    <Eye className="w-4 h-4 mr-1" />
                    Aperçu
                  </Button>
                  <Button 
                    variant="secondary" 
                    size="sm"
                    onClick={() => handleDownload(report)}
                  >
                    <Download className="w-4 h-4 mr-1" />
                    Télécharger
                  </Button>
                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(report.id)}
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Create/Edit Modal */}
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title="Nouveau Rapport">
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Titre"
            value={formData.titre}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData({ ...formData, titre: e.target.value })}
            required
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Type de rapport
            </label>
            <select
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            >
              <option value="COUTS">Coûts</option>
              <option value="PREDICTIONS">Prédictions</option>
              <option value="ANOMALIES">Anomalies</option>
              <option value="PERSONNALISE">Personnalisé</option>
            </select>
          </div>

          <Input
            label="Période"
            value={formData.periode}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData({ ...formData, periode: e.target.value })}
            placeholder="Ex: Janvier 2024, Q1 2024"
            required
          />

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Date de début"
              type="date"
              value={formData.dateDebut}
              min={new Date().toISOString().split('T')[0]}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData({ ...formData, dateDebut: e.target.value })}
              required
            />
            <Input
              label="Date de fin"
              type="date"
              value={formData.dateFin}
              min={formData.dateDebut || new Date().toISOString().split('T')[0]}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData({ ...formData, dateFin: e.target.value })}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Résumé
            </label>
            <textarea
              value={formData.resume}
              onChange={(e) => setFormData({ ...formData, resume: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={3}
            />
          </div>

          <div className="flex justify-end gap-3">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Annuler
            </Button>
            <Button type="submit">
              Créer le rapport
            </Button>
          </div>
        </form>
      </Modal>

      {/* Preview Modal */}
      <Modal 
        isOpen={isPreviewOpen} 
        onClose={() => setIsPreviewOpen(false)} 
        title={`Aperçu: ${selectedReport?.titre}`}
      >
        {selectedReport && (
          <div ref={previewRef} className="bg-white p-6 space-y-6">
            {/* Header */}
            <div className="bg-blue-600 text-white p-6 rounded-lg text-center">
              <h2 className="text-2xl font-bold">Financial Dashboard</h2>
              <p className="text-sm mt-1">Rapport Hospitalier</p>
            </div>

            {/* Title */}
            <h3 className="text-xl font-bold text-gray-900 border-b pb-2">
              {selectedReport.titre}
            </h3>

            {/* Info Grid */}
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="font-semibold text-gray-700">Type:</span>
                <span className="ml-2">{getTypeLabel(selectedReport.type)}</span>
              </div>
              <div>
                <span className="font-semibold text-gray-700">Période:</span>
                <span className="ml-2">{selectedReport.periode}</span>
              </div>
              <div>
                <span className="font-semibold text-gray-700">Date début:</span>
                <span className="ml-2">{new Date(selectedReport.dateDebut).toLocaleDateString('fr-FR')}</span>
              </div>
              <div>
                <span className="font-semibold text-gray-700">Date fin:</span>
                <span className="ml-2">{new Date(selectedReport.dateFin).toLocaleDateString('fr-FR')}</span>
              </div>
              <div>
                <span className="font-semibold text-gray-700">Statut:</span>
                <span className={`ml-2 px-2 py-1 rounded text-xs ${getStatusBadge(selectedReport.statut)}`}>
                  {getStatutLabel(selectedReport.statut)}
                </span>
              </div>
            </div>

            {/* Résumé */}
            {selectedReport.resume && (
              <div>
                <h4 className="font-semibold text-gray-900 mb-2">Résumé</h4>
                <p className="text-gray-700 text-sm">{selectedReport.resume}</p>
              </div>
            )}

            {/* Sample Content */}
            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Contenu du Rapport</h4>
              {selectedReport.type === 'COUTS' && (
                <div className="space-y-4">
                  <table className="w-full text-sm">
                    <thead className="bg-blue-600 text-white">
                      <tr>
                        <th className="p-2 text-left">Service</th>
                        <th className="p-2 text-right">Budget</th>
                        <th className="p-2 text-right">Dépenses</th>
                        <th className="p-2 text-right">Écart</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr className="border-b">
                        <td className="p-2">Cardiologie</td>
                        <td className="p-2 text-right">250 000 €</td>
                        <td className="p-2 text-right">248 500 €</td>
                        <td className="p-2 text-right text-green-600">-1 500 €</td>
                      </tr>
                      <tr className="border-b bg-gray-50">
                        <td className="p-2">Urgences</td>
                        <td className="p-2 text-right">180 000 €</td>
                        <td className="p-2 text-right">185 200 €</td>
                        <td className="p-2 text-right text-red-600">+5 200 €</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}
              {selectedReport.type === 'PREDICTIONS' && (
                <ul className="space-y-2 text-sm">
                  <li>• Augmentation prévue des coûts de 3.2% au Q2 2024</li>
                  <li>• Optimisation possible de 15 000 € sur les achats pharmaceutiques</li>
                  <li>• Budget recommandé pour 2024: 4.2M € (+5% vs 2023)</li>
                </ul>
              )}
              {selectedReport.type === 'ANOMALIES' && (
                <div className="space-y-3">
                  <div className="p-3 bg-red-50 border-l-4 border-red-500 text-sm">
                    <span className="font-semibold text-red-800">[CRITIQUE]</span>
                    <p className="text-gray-700 mt-1">Dépassement budgétaire de 12% en Urgences</p>
                  </div>
                  <div className="p-3 bg-yellow-50 border-l-4 border-yellow-500 text-sm">
                    <span className="font-semibold text-yellow-800">[ATTENTION]</span>
                    <p className="text-gray-700 mt-1">Consommation anormale de matériel médical</p>
                  </div>
                </div>
              )}
            </div>

            {/* Footer */}
            <div className="border-t pt-4 text-center text-xs text-gray-500 italic">
              Généré automatiquement par Financial Dashboard - {new Date().toLocaleDateString('fr-FR')}
            </div>
          </div>
        )}
        
        <div className="flex justify-end gap-3 mt-6">
          <Button variant="secondary" onClick={() => setIsPreviewOpen(false)}>
            Fermer
          </Button>
          <Button onClick={() => selectedReport && handleDownload(selectedReport)}>
            <Download className="w-4 h-4 mr-2" />
            Télécharger PDF
          </Button>
        </div>
      </Modal>
    </div>
  );
};

export { Reports };
