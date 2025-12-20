import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({Key? key}) : super(key: key);

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  String _selectedPeriod = 'Mois';
  List<String> _selectedServices = ['Tous les services'];
  String _selectedHorizon = '3 mois';

  final List<String> _periods = ['Jour', 'Semaine', 'Mois', 'Trimestre', 'Année'];
  final List<String> _services = [
    'Tous les services',
    'Urgences',
    'Chirurgie',
    'Cardiologie',
    'Pédiatrie',
    'Radiologie',
    'Maternité'
  ];
  final List<String> _horizons = ['1 mois', '3 mois', '6 mois', '12 mois'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prédictions financières',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anticipation des dépenses et analyse prédictive',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Regenerate predictions
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Régénérer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Download report
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filters Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Period Filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Période',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedPeriod,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: _periods.map((String period) {
                                return DropdownMenuItem<String>(
                                  value: period,
                                  child: Text(period),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Services Filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildServicesDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Horizon Filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horizon de prévision',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedHorizon,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: _horizons.map((String horizon) {
                                return DropdownMenuItem<String>(
                                  value: horizon,
                                  child: Text(horizon),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedHorizon = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Prediction Result & Influence Factors
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prediction Card
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coût estimé du prochain mois',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Juillet 2025',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green[600],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Confiance élevée',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '625 000 €',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+2.5%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intervalle de confiance: 600 000 € - 650 000 €',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 250,
                          child: _buildPredictionChart(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                
                // Influence Factors
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facteurs d\'influence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInfluenceFactor(
                          icon: Icons.trending_up,
                          iconColor: Colors.blue[600]!,
                          title: 'Saisonnalité',
                          impact: 'Impact: +3%',
                          progress: 0.75,
                          progressColor: Colors.blue[600]!,
                        ),
                        const SizedBox(height: 32),
                        _buildInfluenceFactor(
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange[600]!,
                          title: 'Inflation',
                          impact: 'Impact: +2.1%',
                          progress: 0.6,
                          progressColor: Colors.orange[600]!,
                        ),
                        const SizedBox(height: 32),
                        _buildInfluenceFactor(
                          icon: Icons.trending_down,
                          iconColor: Colors.green[600]!,
                          title: 'Optimisations',
                          impact: 'Impact: -1.5%',
                          progress: 0.45,
                          progressColor: Colors.green[600]!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Prévisions par service Table
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prévisions par service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildServicePredictionsTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesDropdown() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedServices.join(', '),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return _services.map((String service) {
          final isSelected = _selectedServices.contains(service);
          return CheckedPopupMenuItem<String>(
            value: service,
            checked: isSelected,
            child: Text(service),
          );
        }).toList();
      },
      onSelected: (String value) {
        setState(() {
          if (value == 'Tous les services') {
            _selectedServices = ['Tous les services'];
          } else {
            _selectedServices.remove('Tous les services');
            if (_selectedServices.contains(value)) {
              _selectedServices.remove(value);
            } else {
              _selectedServices.add(value);
            }
            if (_selectedServices.isEmpty) {
              _selectedServices = ['Tous les services'];
            }
          }
        });
      },
    );
  }

  Widget _buildInfluenceFactor({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String impact,
    required double progress,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          impact,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionChart() {
    final spots = [
      const FlSpot(0, 620),
      const FlSpot(1, 625),
      const FlSpot(2, 628),
      const FlSpot(3, 630),
      const FlSpot(4, 635),
      const FlSpot(5, 640),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}k',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal[600],
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.teal[600]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${(spot.y * 1000).toInt()} €',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServicePredictionsTable() {
    final serviceData = [
      {
        'service': 'Urgences',
        'actuel': 120000,
        'prevu': 128000,
        'variation': 6.7,
        'risque': 'Moyen',
        'risqueColor': Colors.orange[100]!,
      },
      {
        'service': 'Chirurgie',
        'actuel': 180000,
        'prevu': 195000,
        'variation': 8.3,
        'risque': 'Élevé',
        'risqueColor': Colors.red[100]!,
      },
      {
        'service': 'Cardiologie',
        'actuel': 95000,
        'prevu': 98000,
        'variation': 3.2,
        'risque': 'Faible',
        'risqueColor': Colors.green[100]!,
      },
      {
        'service': 'Pédiatrie',
        'actuel': 75000,
        'prevu': 77000,
        'variation': 2.7,
        'risque': 'Faible',
        'risqueColor': Colors.green[100]!,
      },
      {
        'service': 'Radiologie',
        'actuel': 85000,
        'prevu': 89000,
        'variation': 4.7,
        'risque': 'Moyen',
        'risqueColor': Colors.orange[100]!,
      },
      {
        'service': 'Maternité',
        'actuel': 55000,
        'prevu': 57000,
        'variation': 3.6,
        'risque': 'Faible',
        'risqueColor': Colors.green[100]!,
      },
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader('Service'),
            _buildTableHeader('Actuel'),
            _buildTableHeader('Prévu'),
            _buildTableHeader('Variation'),
            _buildTableHeader('Risque'),
          ],
        ),
        // Data rows
        ...serviceData.map((data) {
          return TableRow(
            children: [
              _buildTableCell(
                data['service'] as String,
                isFirst: true,
              ),
              _buildTableCell(
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: '€',
                  decimalDigits: 0,
                ).format(data['actuel']),
              ),
              _buildTableCell(
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: '€',
                  decimalDigits: 0,
                ).format(data['prevu']),
                isBold: true,
              ),
              _buildTableCell(
                '+${data['variation']}%',
                color: Colors.red[700],
              ),
              _buildTableCell(
                data['risque'] as String,
                backgroundColor: data['risqueColor'] as Color,
                centered: true,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isFirst = false,
    bool isBold = false,
    Color? color,
    Color? backgroundColor,
    bool centered = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: backgroundColor != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: color ?? Colors.grey[800],
                ),
              ),
            )
          : Text(
              text,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isFirst || isBold ? FontWeight.w600 : FontWeight.normal,
                color: color ?? Colors.grey[800],
              ),
            ),
    );
  }
}
