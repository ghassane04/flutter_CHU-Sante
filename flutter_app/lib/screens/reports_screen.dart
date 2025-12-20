import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/report_provider.dart';
import 'package:flutter_app/models/index.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedType;
  String? _selectedPeriode;
  String? _selectedStatut;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportProvider>().fetchReports());
  }

  List<Report> _getFilteredReports(List<Report> reports) {
    return reports.where((report) {
      bool matchesType = _selectedType == null || _selectedType == 'Tous les types' || report.type == _selectedType;
      bool matchesPeriode = _selectedPeriode == null || _selectedPeriode == 'Toutes les périodes' || report.periode == _selectedPeriode;
      bool matchesStatut = _selectedStatut == null || _selectedStatut == 'Tous les statuts' || report.statut == _selectedStatut;
      return matchesType && matchesPeriode && matchesStatut;
    }).toList();
  }

  Map<String, int> _getStatistics(List<Report> reports, List<Report> filteredReports) {
    return {
      'total': reports.length,
      'brouillons': reports.where((r) => r.statut == 'BROUILLON').length,
      'publies': reports.where((r) => r.statut == 'PUBLIE').length,
      'filtres': filteredReports.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                'Erreur: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final filteredReports = _getFilteredReports(provider.reports);
          final stats = _getStatistics(provider.reports, filteredReports);

          return Column(
            children: [
              _buildHeader(),
              _buildFiltersAndStats(provider.reports, stats),
              Expanded(
                child: filteredReports.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(filteredReports[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rapports',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateReportDialog();
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nouveau rapport'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndStats(List<Report> allReports, Map<String, int> stats) {
    // Extract unique values for dropdowns
    final types = ['Tous les types', ...allReports.map((r) => r.type).toSet().toList()];
    final periodes = ['Toutes les périodes', ...allReports.map((r) => r.periode).toSet().toList()];
    final statuts = ['Tous les statuts', ...allReports.map((r) => r.statut).toSet().toList()];

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          // Filters row
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: Colors.grey[400]),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  value: _selectedType ?? 'Tous les types',
                  items: types,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value == 'Tous les types' ? null : value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  value: _selectedPeriode ?? 'Toutes les périodes',
                  items: periodes,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value == 'Toutes les périodes' ? null : value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  value: _selectedStatut ?? 'Tous les statuts',
                  items: statuts,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatut = value == 'Tous les statuts' ? null : value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', stats['total']!, Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Brouillons', stats['brouillons']!, Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Publiés', stats['publies']!, Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Filtrés', stats['filtres']!, Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun rapport trouvé',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    Color statusColor;
    switch (report.statut) {
      case 'PUBLIE':
        statusColor = Colors.green;
        break;
      case 'ARCHIVE':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.statut,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Type: ${report.type}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  'Période: ${report.periode}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (report.resume != null) ...[
              const SizedBox(height: 8),
              Text(report.resume!),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Du ${DateFormat('dd/MM/yyyy').format(report.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(report.dateFin)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (report.generePar != null)
                        Text(
                          'Par: ${report.generePar}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () {
                        _viewReport(report);
                      },
                      tooltip: 'Voir le rapport',
                      color: Colors.blue[700],
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {
                        _downloadReportPDF(report);
                      },
                      tooltip: 'Télécharger en PDF',
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.titre,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewSection('Type', report.type),
                      _buildPreviewSection('Période', report.periode),
                      _buildPreviewSection('Dates', 
                        '${DateFormat('dd/MM/yyyy').format(report.dateDebut)} - ${DateFormat('dd/MM/yyyy').format(report.dateFin)}'),
                      if (report.generePar != null)
                        _buildPreviewSection('Généré par', report.generePar!),
                      if (report.resume != null)
                        _buildPreviewSection('Résumé', report.resume!),
                      if (report.donneesPrincipales != null)
                        _buildPreviewSection('Données Principales', report.donneesPrincipales!),
                      if (report.conclusions != null)
                        _buildPreviewSection('Conclusions', report.conclusions!),
                      if (report.recommandations != null)
                        _buildPreviewSection('Recommandations', report.recommandations!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadReportPDF(report);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReportPDF(Report report) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Génération du PDF pour "${report.titre}"...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Generate PDF
      final pdf = await _generateReportPDF(report);
      
      // Save and open PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${report.titre}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF généré avec succès pour "${report.titre}"'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generateReportPDF(Report report) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      report.titre,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Type: ${report.type} | Période: ${report.periode}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Report Information
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFRow('Statut', report.statut),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'Période',
                      'Du ${DateFormat('dd/MM/yyyy').format(report.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(report.dateFin)}',
                    ),
                    if (report.generePar != null) ...[
                      pw.SizedBox(height: 8),
                      _buildPDFRow('Généré par', report.generePar!),
                    ],
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'Date de génération',
                      DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
              
              // Resume section
              if (report.resume != null) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Résumé',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    report.resume!,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              ],
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'CHU Santé - Finance Dashboard',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Page 1',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  pw.Widget _buildPDFRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showCreateReportDialog() {
    final formKey = GlobalKey<FormState>();
    final titreController = TextEditingController();
    final typeController = TextEditingController();
    final periodeController = TextEditingController();
    final resumeController = TextEditingController();
    final donneesPrincipalesController = TextEditingController();
    final conclusionsController = TextEditingController();
    final recommandationsController = TextEditingController();
    DateTime dateDebut = DateTime.now();
    DateTime dateFin = DateTime.now().add(const Duration(days: 30));
    String selectedStatut = 'BROUILLON';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue),
              SizedBox(width: 12),
              Text('Créer un nouveau rapport'),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    TextFormField(
                      controller: titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre du rapport *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le titre est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Type and Période
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: typeController,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                              hintText: 'MENSUEL, ANNUEL...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Le type est requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: periodeController,
                            decoration: const InputDecoration(
                              labelText: 'Période *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                              hintText: 'Q1 2025, Décembre...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La période est requise';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Début and Date Fin
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dateDebut,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  dateDebut = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date début *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(dateDebut),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dateFin,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  dateFin = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date fin *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(dateFin),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Statut
                    DropdownButtonFormField<String>(
                      value: selectedStatut,
                      decoration: const InputDecoration(
                        labelText: 'Statut *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: ['BROUILLON', 'PUBLIE', 'ARCHIVE'].map((statut) {
                        return DropdownMenuItem(
                          value: statut,
                          child: Text(statut),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatut = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Résumé
                    TextFormField(
                      controller: resumeController,
                      decoration: const InputDecoration(
                        labelText: 'Résumé',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Bref résumé du rapport...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Données principales
                    TextFormField(
                      controller: donneesPrincipalesController,
                      decoration: const InputDecoration(
                        labelText: 'Données principales',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.data_usage),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Conclusions
                    TextFormField(
                      controller: conclusionsController,
                      decoration: const InputDecoration(
                        labelText: 'Conclusions',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Recommandations
                    TextFormField(
                      controller: recommandationsController,
                      decoration: const InputDecoration(
                        labelText: 'Recommandations',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lightbulb_outline),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (dateFin.isBefore(dateDebut)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La date de fin doit être après la date de début'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final report = Report(
                    titre: titreController.text.trim(),
                    type: typeController.text.trim().toUpperCase(),
                    periode: periodeController.text.trim(),
                    resume: resumeController.text.trim().isEmpty ? null : resumeController.text.trim(),
                    dateDebut: dateDebut,
                    dateFin: dateFin,
                    donneesPrincipales: donneesPrincipalesController.text.trim().isEmpty ? null : donneesPrincipalesController.text.trim(),
                    conclusions: conclusionsController.text.trim().isEmpty ? null : conclusionsController.text.trim(),
                    recommandations: recommandationsController.text.trim().isEmpty ? null : recommandationsController.text.trim(),
                    statut: selectedStatut,
                    generePar: 'Admin', // TODO: Get from authenticated user
                  );

                  // Get the provider and navigator before popping
                  final provider = context.read<ReportProvider>();
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  
                  // Pop the dialog
                  navigator.pop();

                  // Create the report
                  final success = await provider.createReport(report);

                  // Show result message
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Rapport "${report.titre}" créé avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur: ${provider.errorMessage ?? "Impossible de créer le rapport"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Créer le rapport'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
