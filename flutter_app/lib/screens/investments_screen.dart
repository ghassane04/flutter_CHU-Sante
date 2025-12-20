import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/investment_provider.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';

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
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<InvestmentProvider>(
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

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    ...provider.investments.map((inv) => _buildInvestmentCard(inv)).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
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
          Text('Gestion du portefeuille d\'investissements hospitaliers', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showInvestmentDialog(null),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nouvel investissement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(InvestmentStats stats) {
    return ResponsiveLayout.isMobile(context)
        ? Column(
            children: [
              _buildStatCard('Budget total disponible', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(stats.budgetTotal)}', Icons.attach_money, const Color(0xFF0284C7)),
              const SizedBox(height: 12),
              _buildStatCard('ROI estimé total', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(stats.roiTotal)}', Icons.trending_up, const Color(0xFF10B981)),
              const SizedBox(height: 12),
              _buildStatCard('Projets actifs', '${stats.projetsActifs}', Icons.calendar_today, const Color(0xFFF97316)),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildStatCard('Budget total disponible', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(stats.budgetTotal)}', Icons.attach_money, const Color(0xFF0284C7))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('ROI estimé total', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(stats.roiTotal)}', Icons.trending_up, const Color(0xFF10B981))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Projets actifs', '${stats.projetsActifs}', Icons.calendar_today, const Color(0xFFF97316))),
            ],
          );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
    Color statutColor;
    String statutLabel;
    switch (investment.statut) {
      case 'EN_COURS':
        statutColor = const Color(0xFF10B981);
        statutLabel = 'EN COURS';
        break;
      case 'PLANIFIE':
        statutColor = const Color(0xFF0284C7);
        statutLabel = 'PLANIFIÉ';
        break;
      case 'TERMINE':
        statutColor = const Color(0xFF6B7280);
        statutLabel = 'TERMINÉ';
        break;
      default:
        statutColor = Colors.grey;
        statutLabel = investment.statut;
    }

    Color risqueColor;
    String risqueLabel;
    switch (investment.niveauRisque) {
      case 'ELEVE':
        risqueColor = const Color(0xFFEF4444);
        risqueLabel = 'ÉLEVÉ';
        break;
      case 'MOYEN':
        risqueColor = const Color(0xFFF97316);
        risqueLabel = 'MOYEN';
        break;
      case 'FAIBLE':
        risqueColor = const Color(0xFF10B981);
        risqueLabel = 'FAIBLE';
        break;
      default:
        risqueColor = Colors.grey;
        risqueLabel = investment.niveauRisque ?? 'N/A';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(investment.nom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                      const SizedBox(height: 4),
                      Text(investment.description ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: risqueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(risqueLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: risqueColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Montant', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text('${NumberFormat.currency(locale: 'fr', symbol: '€').format(investment.montant)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ROI', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text('${investment.retourInvestissement?.toStringAsFixed(0) ?? 0}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catégorie', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(investment.categorie, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fin prévue', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(_formatDate(investment.dateFinPrevue?.toIso8601String() ?? ''), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Voir détails'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showInvestmentDialog(investment),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(investment),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  void _showInvestmentDialog(Investment? investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(investment == null ? 'Nouvel Investissement' : 'Modifier Investissement'),
        content: const Text('Formulaire à implémenter'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'investissement'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${investment.nom} ?'),
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
