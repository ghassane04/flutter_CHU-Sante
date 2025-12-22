import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/investment_provider.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<InvestmentProvider>().fetchInvestments();
      context.read<InvestmentProvider>().fetchInvestmentStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<InvestmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Erreur: ${provider.errorMessage}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final stats = provider.investmentStats;
          final investments = provider.investments;

          // Calculate category totals for pie chart
          final categoryTotals = <String, double>{};
          for (var inv in investments) {
            categoryTotals[inv.categorie] = (categoryTotals[inv.categorie] ?? 0) + inv.montant;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header with button
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Stats cards
              if (stats != null) _buildStatsCards(stats),
              const SizedBox(height: 24),
              
              // Pie chart and legend
              if (categoryTotals.isNotEmpty) _buildBudgetChart(categoryTotals),
              const SizedBox(height: 24),
              
              // Investment cards
              ...investments.map((inv) => _buildInvestmentCard(inv)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Investissements',
                style: TextStyle(
                  fontSize: ResponsiveLayout.isMobile(context) ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text('Gestion du portefeuille d\'investissements hospitaliers', 
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showInvestmentDialog(null),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Nouvel investissement'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(InvestmentStats stats) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final cards = [
      _buildStatCard(
        'Budget total disponible',
        NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: 0).format(stats.budgetTotal),
        Icons.attach_money,
        const Color(0xFF3B82F6),
      ),
      _buildStatCard(
        'ROI estimé total',
        NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: 0).format(stats.roiTotal),
        Icons.trending_up,
        const Color(0xFF10B981),
      ),
      _buildStatCard(
        'Projets actifs',
        '${stats.projetsActifs}',
        Icons.calendar_today,
        const Color(0xFFF97316),
      ),
    ];

    return isMobile
        ? Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList())
        : Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList());
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChart(Map<String, double> categoryTotals) {
    final colors = {
      'EQUIPEMENT': const Color(0xFF3B82F6),
      'INFRASTRUCTURE': const Color(0xFF14B8A6),
      'TECHNOLOGIE': const Color(0xFF10B981),
      'FORMATION': const Color(0xFFF97316),
    };

    final total = categoryTotals.values.fold<double>(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition du budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: categoryTotals.entries.map((entry) {
                  final percentage = (entry.value / total * 100).round();
                  final color = colors[entry.key] ?? Colors.grey;
                  return PieChartSectionData(
                    value: entry.value,
                    color: color,
                    title: '$percentage%',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    radius: 60,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...categoryTotals.entries.map((entry) {
            final color = colors[entry.key] ?? Colors.grey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text(
                    NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: 0).format(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
    // Status colors and labels
    Color statutColor;
    String statutLabel;
    switch (investment.statut) {
      case 'EN_COURS':
        statutColor = const Color(0xFF10B981);
        statutLabel = 'En cours';
        break;
      case 'EN_ATTENTE':
        statutColor = const Color(0xFF6B7280);
        statutLabel = 'En attente';
        break;
      case 'PLANIFIE':
        statutColor = const Color(0xFF0284C7);
        statutLabel = 'Planifié';
        break;
      case 'TERMINE':
        statutColor = const Color(0xFF6B7280);
        statutLabel = 'Terminé';
        break;
      default:
        statutColor = Colors.grey;
        statutLabel = investment.statut;
    }

    // Risk colors
    Color risqueColor;
    String risqueLabel;
    switch (investment.niveauRisque) {
      case 'ELEVE':
        risqueColor = const Color(0xFFEF4444);
        risqueLabel = 'Risque Élevé';
        break;
      case 'MOYEN':
        risqueColor = const Color(0xFFF97316);
        risqueLabel = 'Risque Moyen';
        break;
      case 'FAIBLE':
        risqueColor = const Color(0xFF10B981);
        risqueLabel = 'Risque Faible';
        break;
      default:
        risqueColor = Colors.grey;
        risqueLabel = 'N/A';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      investment.nom,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statutColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(statutLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statutColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          if (investment.description.isNotEmpty)
            Text(investment.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          
          // Info grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Montant', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: 0).format(investment.montant),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROI estimé', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      '+${investment.retourInvestissement?.toStringAsFixed(0) ?? 0}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catégorie', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(investment.categorie, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Échéance', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text(
                      investment.dateFinPrevue != null
                          ? DateFormat('dd/MM/yyyy').format(investment.dateFinPrevue!)
                          : 'Non définie',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Risk indicator bar
          if (investment.niveauRisque != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: risqueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(risqueLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: risqueColor)),
            ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              TextButton(
                onPressed: () => _showDetailsDialog(investment),
                child: Text('Voir détails', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => _showInvestmentDialog(investment),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[700]),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: Colors.red[500], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => _showDeleteConfirmation(investment),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(Investment investment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(investment.nom, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Catégorie', investment.categorie),
              _buildDetailRow('Montant', NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: 0).format(investment.montant)),
              _buildDetailRow('ROI estimé', '+${investment.retourInvestissement?.toStringAsFixed(0) ?? 0}%'),
              _buildDetailRow('Statut', investment.statut),
              _buildDetailRow('Niveau de risque', investment.niveauRisque ?? 'N/A'),
              if (investment.fournisseur != null) _buildDetailRow('Fournisseur', investment.fournisseur!),
              if (investment.responsable != null) _buildDetailRow('Responsable', investment.responsable!),
              _buildDetailRow('Date début', DateFormat('dd/MM/yyyy').format(investment.dateInvestissement)),
              if (investment.dateFinPrevue != null) _buildDetailRow('Date fin prévue', DateFormat('dd/MM/yyyy').format(investment.dateFinPrevue!)),
              if (investment.beneficesAttendus != null) ...[
                const SizedBox(height: 12),
                const Text('Bénéfices attendus', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(investment.beneficesAttendus!, style: TextStyle(color: Colors.grey[700])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showInvestmentDialog(Investment? investment) {
    final formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: investment?.nom ?? '');
    final categorieController = TextEditingController(text: investment?.categorie ?? '');
    final descriptionController = TextEditingController(text: investment?.description ?? '');
    final montantController = TextEditingController(text: investment?.montant.toString() ?? '0');
    final roiController = TextEditingController(text: investment?.retourInvestissement?.toString() ?? '0');
    final fournisseurController = TextEditingController(text: investment?.fournisseur ?? '');
    DateTime dateDebut = investment?.dateInvestissement ?? DateTime.now();
    DateTime? dateFin = investment?.dateFinPrevue;
    String selectedStatut = investment?.statut ?? 'PLANIFIE';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            investment == null ? 'Nouvel investissement' : 'Modifier investissement',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  
                  // Form content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField('Nom de l\'investissement', nomController, 'Ex: Nouveau scanner IRM'),
                          _buildFormField('Catégorie', categorieController, 'Ex: Équipement médical'),
                          _buildFormField('Description', descriptionController, 'Description du projet', maxLines: 2),
                          _buildFormField('Montant (€)', montantController, '0', isNumber: true),
                          _buildFormField('ROI estimé (%)', roiController, '0', isNumber: true),
                          
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
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[400]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(DateFormat('dd/MM/yyyy').format(dateDebut))),
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
                                    const Text('Date de fin prévue', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: dateFin ?? DateTime.now().add(const Duration(days: 365)),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setState(() => dateFin = picked);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[400]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(dateFin != null ? DateFormat('dd/MM/yyyy').format(dateFin!) : 'jj/mm/aaaa')),
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
                          
                          // Statut dropdown
                          const Text('Statut', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedStatut,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            items: ['PLANIFIE', 'EN_COURS', 'EN_ATTENTE', 'TERMINE'].map((s) {
                              return DropdownMenuItem(value: s, child: Text(s == 'PLANIFIE' ? 'Planifié' : s == 'EN_COURS' ? 'En cours' : s == 'EN_ATTENTE' ? 'En attente' : 'Terminé'));
                            }).toList(),
                            onChanged: (v) { if (v != null) setState(() => selectedStatut = v); },
                          ),
                          const SizedBox(height: 16),
                          
                          _buildFormField('Fournisseur', fournisseurController, 'Nom du fournisseur'),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final newInvestment = Investment(
                                  id: investment?.id,
                                  nom: nomController.text.trim(),
                                  categorie: categorieController.text.trim().toUpperCase(),
                                  description: descriptionController.text.trim(),
                                  montant: double.tryParse(montantController.text) ?? 0,
                                  dateInvestissement: dateDebut,
                                  dateFinPrevue: dateFin,
                                  statut: selectedStatut,
                                  fournisseur: fournisseurController.text.trim().isEmpty ? null : fournisseurController.text.trim(),
                                  retourInvestissement: double.tryParse(roiController.text),
                                );

                                final provider = context.read<InvestmentProvider>();
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                
                                try {
                                  if (investment == null) {
                                    await provider.createInvestment(newInvestment);
                                  } else {
                                    await provider.updateInvestment(newInvestment.id!, newInvestment);
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Investissement ${investment == null ? "créé" : "modifié"} avec succès'), backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint, {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'investissement'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${investment.nom}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<InvestmentProvider>().deleteInvestment(investment.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Investissement supprimé avec succès'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
