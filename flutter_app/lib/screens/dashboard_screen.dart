import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/providers/dashboard_provider.dart';
import 'package:flutter_app/models/index.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<DashboardProvider>().loadDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tableau de Bord',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827), // gray-900
                ),
              ),
              ElevatedButton(
                onPressed: () => context.read<DashboardProvider>().loadDashboardData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF), // blue-50
                  foregroundColor: const Color(0xFF2563EB), // blue-600
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Actualiser'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(child: Text('Erreur: ${provider.error}', style: const TextStyle(color: Colors.red)));
              }
              final stats = provider.stats;
              if (stats == null) return const SizedBox.shrink();

              return Column(
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: KPICard(
                          title: 'Total Patients',
                          value: stats.totalPatients.toString(),
                          icon: Icons.people_outline,
                          iconBg: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: KPICard(
                          title: 'Séjours en Cours',
                          value: stats.sejoursEnCours.toString(),
                          icon: Icons.bed,
                          iconBg: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: KPICard(
                          title: 'Actes Médicaux',
                          value: stats.totalActes.toString(),
                          icon: Icons.monitor_heart_outlined,
                          iconBg: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: KPICard(
                          title: 'Revenus du Mois',
                          value: '${NumberFormat.currency(symbol: '€', decimalDigits: 0, locale: 'fr_FR').format(stats.revenusMois)}',
                          subtitle: 'Année: ${NumberFormat.currency(symbol: '€', decimalDigits: 0, locale: 'fr_FR').format(stats.revenusAnnee)}',
                          icon: Icons.trending_up,
                          iconBg: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Overview & Revenue Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vue d'ensemble
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vue d\'ensemble',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildOverviewRow('Patients enregistrés', stats.totalPatients.toString(), Colors.blue),
                              _buildOverviewRow('Séjours actifs', stats.sejoursEnCours.toString(), Colors.green),
                              _buildOverviewRow('Actes réalisés', stats.totalActes.toString(), Colors.purple),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Revenue Breakdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.trending_up, color: Colors.orange[600], size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Revenus',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRevenueRow('Total du mois', stats.revenusMois, Colors.orange),
                              _buildRevenueRow('Total de l\'année', stats.revenusAnnee, Colors.green),
                              _buildRevenueRow('Revenus totaux', stats.revenusTotal, Colors.blue),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Moyenne par acte', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                  Text(
                                    stats.totalActes > 0 ? '${(stats.revenusMois / stats.totalActes).toStringAsFixed(2)} €' : '0 €',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actes par Type (BarChart)
                      Expanded(
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.purple[600]),
                                  const SizedBox(width: 8),
                                  const Text('Actes Médicaux par Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(child: _buildBarChart(provider.actesByType)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Séjours par Service (PieChart)
                      Expanded(
                        child: Container(
                          height: 350,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pie_chart, color: Colors.green[600]),
                                  const SizedBox(width: 8),
                                  const Text('Séjours par Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(child: _buildPieChart(provider.sejoursByService)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Revenus par Mois Chart (LineChart)
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.show_chart, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            const Text('Évolution des Revenus Mensuels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(child: _buildLineChart(provider.revenusByMonth)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guide de demarrage
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)]), // blue-50 to indigo-50
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDBEAFE)), // blue-100
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guide de démarrage rapide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGuideStep('1', 'Créer des services', 'Ajoutez les différents services hospitaliers'),
                            const SizedBox(width: 16),
                            _buildGuideStep('2', 'Enregistrer des patients', 'Créez les fiches des patients'),
                            const SizedBox(width: 16),
                            _buildGuideStep('3', 'Gérer les séjours', 'Suivez l\'admission et la sortie des patients'),
                            const SizedBox(width: 16),
                            _buildGuideStep('4', 'Enregistrer les actes', 'Documentez tous les actes effectués'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            NumberFormat.currency(symbol: '€', decimalDigits: 0, locale: 'fr_FR').format(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16), // Adjusted size
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<ActesByTypeStats> data) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)));

    final maxValue = data.fold<double>(0, (max, e) => e.count.toDouble() > max ? e.count.toDouble() : max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final type = data[value.toInt()].type;
                  final displayText = type.length >= 3 ? type.substring(0, 3) : type;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(displayText, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.count.toDouble(),
                color: const Color(0xFF8B5CF6), // purple-500
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<SejoursByServiceStats> data) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)));
    
    // Simple colors list
    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.red, Colors.pink];

    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return PieChartSectionData(
            value: item.count.toDouble(),
            title: '${item.count}',
            color: colors[index % colors.length],
            radius: 80,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildLineChart(List<RevenusByMonthStats> data) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final month = data[value.toInt()].month;
                  final displayText = month.length >= 3 ? month.substring(0, 3) : month;
                  return Text(displayText);
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
            isCurved: true,
            color: const Color(0xFF3B82F6), // blue-500
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconBg;

  const KPICard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconBg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg, // Using the full color derived from React logic
                  borderRadius: BorderRadius.circular(50), // rounded-full
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
