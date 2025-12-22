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
    // Colors for type badges
    Color typeColor;
    switch (report.type.toLowerCase()) {
      case 'coûts':
      case 'couts':
        typeColor = Colors.blue;
        break;
      case 'prédictions':
      case 'predictions':
        typeColor = Colors.purple;
        break;
      case 'anomalies':
        typeColor = Colors.orange;
        break;
      default:
        typeColor = Colors.grey;
    }

    // Colors for status badges
    Color statusColor;
    String statusText;
    switch (report.statut) {
      case 'PUBLIE':
        statusColor = Colors.green;
        statusText = 'Publié';
        break;
      case 'ARCHIVE':
        statusColor = Colors.grey;
        statusText = 'Archivé';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Brouillon';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  report.titre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Period and dates
                Text(
                  '${report.periode} • ${DateFormat('dd/MM/yyyy').format(report.dateDebut)} - ${DateFormat('dd/MM/yyyy').format(report.dateFin)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aperçu button
              ElevatedButton.icon(
                onPressed: () => _viewReport(report),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Aperçu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6), // Teal
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              // Télécharger button
              ElevatedButton.icon(
                onPressed: () => _downloadReportPDF(report),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Télécharger'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9), // Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[500],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () => _confirmDeleteReport(report),
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Supprimer',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le rapport "${report.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ReportProvider>().deleteReport(report.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rapport supprimé'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewReport(Report report) {
    // Status color and text
    Color statusColor;
    String statusText;
    switch (report.statut) {
      case 'PUBLIE':
        statusColor = Colors.green;
        statusText = 'Publié';
        break;
      case 'ARCHIVE':
        statusColor = Colors.grey;
        statusText = 'Archivé';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Brouillon';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Aperçu: ${report.titre}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blue banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Financial Dashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rapport Hospitalier',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        report.titre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Divider(height: 24),
                      
                      // Info grid
                      Wrap(
                        spacing: 32,
                        runSpacing: 12,
                        children: [
                          _buildInfoItem('Type:', report.type),
                          _buildInfoItem('Période:', report.periode),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 32,
                        runSpacing: 12,
                        children: [
                          _buildInfoItem('Date début:', DateFormat('dd/MM/yyyy').format(report.dateDebut)),
                          _buildInfoItem('Date fin:', DateFormat('dd/MM/yyyy').format(report.dateFin)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Status badge
                      Row(
                        children: [
                          const Text('Statut: ', style: TextStyle(color: Color(0xFF6B7280))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Resume section
                      if (report.resume != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Résumé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.resume!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                        ),
                      ],
                      
                      // Contenu du Rapport
                      if (report.donneesPrincipales != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Contenu du Rapport',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...report.donneesPrincipales!.split('\n').map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(line, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                            ],
                          ),
                        )),
                      ],
                      
                      // Footer
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'Généré automatiquement par Financial Dashboard - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _downloadReportPDF(report);
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Télécharger PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
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
    final periodeController = TextEditingController();
    final resumeController = TextEditingController();
    DateTime dateDebut = DateTime.now();
    DateTime dateFin = DateTime.now().add(const Duration(days: 30));
    String selectedType = 'Coûts';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nouveau Rapport',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Titre
                  const Text('Titre', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titreController,
                    decoration: InputDecoration(
                      hintText: 'Entrez le titre du rapport',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Le titre est requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // Type de rapport
                  const Text('Type de rapport', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: ['Coûts', 'Prédictions', 'Anomalies', 'Analyse', 'Mensuel', 'Annuel'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedType = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Période
                  const Text('Période', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: periodeController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Janvier 2024, Q1 2024',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'La période est requise' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dates row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date de début', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dateDebut,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) setState(() => dateDebut = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(DateFormat('dd/MM/yyyy').format(dateDebut)),
                                    const Spacer(),
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date de fin', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dateFin,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) setState(() => dateFin = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(DateFormat('dd/MM/yyyy').format(dateFin)),
                                    const Spacer(),
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Résumé
                  const Text('Résumé', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: resumeController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Bref résumé du rapport...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (dateFin.isBefore(dateDebut)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('La date de fin doit être après la date de début'), backgroundColor: Colors.red),
                              );
                              return;
                            }

                            final report = Report(
                              titre: titreController.text.trim(),
                              type: selectedType,
                              periode: periodeController.text.trim(),
                              resume: resumeController.text.trim().isEmpty ? null : resumeController.text.trim(),
                              dateDebut: dateDebut,
                              dateFin: dateFin,
                              statut: 'BROUILLON',
                              generePar: 'Admin',
                            );

                            final provider = context.read<ReportProvider>();
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            
                            navigator.pop();
                            final success = await provider.createReport(report);

                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Rapport "${report.titre}" créé avec succès'), backgroundColor: Colors.green),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Erreur: ${provider.errorMessage ?? "Impossible de créer le rapport"}'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Créer le rapport', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
