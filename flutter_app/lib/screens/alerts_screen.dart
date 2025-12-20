import 'package:flutter/material.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/providers/alert_provider.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _searchQuery = '';
  String? _filterPriorite;
  String? _filterStatut;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().fetchAlerts();
      context.read<AlertProvider>().fetchAlertStats();
    });
  }

  List<Alert> _getFilteredAlerts(List<Alert> alerts) {
    return alerts.where((alert) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = alert.titre.toLowerCase().contains(query) ||
                       alert.message.toLowerCase().contains(query) ||
                       alert.categorie.toLowerCase().contains(query);
      }

      bool matchesPriorite = _filterPriorite == null || alert.priorite == _filterPriorite;
      bool matchesStatut = _filterStatut == null || 
                          (_filterStatut == 'RESOLU' && alert.resolu) ||
                          (_filterStatut == 'NON_RESOLU' && !alert.resolu);
      
      bool matchesDate = true;
      if (_filterDate != null && alert.createdAt != null) {
        matchesDate = alert.createdAt!.year == _filterDate!.year &&
                     alert.createdAt!.month == _filterDate!.month &&
                     alert.createdAt!.day == _filterDate!.day;
      }

      return matchesSearch && matchesPriorite && matchesStatut && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        final stats = provider.alertStats;
        final filteredAlerts = _getFilteredAlerts(provider.alerts);
        
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              // Header avec stats
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, size: 32, color: Colors.orange[700]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gestion des Alertes',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                              ),
                              Text(
                                '${provider.alerts.length} alertes au total',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (stats != null) ...[
                      const SizedBox(height: 24),
                      ResponsiveLayout.isMobile(context)
                          ? Column(
                              children: [
                                _buildStatCard('Total', stats['total'].toString(), Icons.notifications, const Color(0xFF0284C7)),
                                const SizedBox(height: 12),
                                _buildStatCard('Critiques', stats['critiques'].toString(), Icons.priority_high, const Color(0xFFEF4444)),
                                const SizedBox(height: 12),
                                _buildStatCard('Résolues', stats['resolues'].toString(), Icons.check_circle, const Color(0xFF10B981)),
                                const SizedBox(height: 12),
                                _buildStatCard('Taux', '${stats['tauxResolution']}%', Icons.trending_up, const Color(0xFF8B5CF6)),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildStatCard('Total', stats['total'].toString(), Icons.notifications, const Color(0xFF0284C7))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard('Critiques', stats['critiques'].toString(), Icons.priority_high, const Color(0xFFEF4444))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard('Résolues', stats['resolues'].toString(), Icons.check_circle, const Color(0xFF10B981))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard('Taux', '${stats['tauxResolution']}%', Icons.trending_up, const Color(0xFF8B5CF6))),
                              ],
                            ),
                    ],
                  ],
                ),
              ),
              
              // Filtres
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SearchBarWidget(
                      hintText: 'Rechercher par titre, message, catégorie...',
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    ResponsiveLayout.isMobile(context)
                        ? Column(
                            children: [
                              _buildFilterDropdown('Priorité', _filterPriorite, ['CRITIQUE', 'ELEVEE', 'MOYENNE', 'FAIBLE'], 
                                (value) => setState(() => _filterPriorite = value)),
                              const SizedBox(height: 12),
                              _buildFilterDropdown('Statut', _filterStatut, ['RESOLU', 'NON_RESOLU'], 
                                (value) => setState(() => _filterStatut = value)),
                              const SizedBox(height: 12),
                              _buildDatePicker(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown('Priorité', _filterPriorite, ['CRITIQUE', 'ELEVEE', 'MOYENNE', 'FAIBLE'], 
                                  (value) => setState(() => _filterPriorite = value)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFilterDropdown('Statut', _filterStatut, ['RESOLU', 'NON_RESOLU'], 
                                  (value) => setState(() => _filterStatut = value)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDatePicker()),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _filterPriorite = null;
                                    _filterStatut = null;
                                    _filterDate = null;
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.clear, size: 18),
                                label: const Text('Réinitialiser'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.grey[700],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              
              // Liste des alertes
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAlerts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty && _filterPriorite == null && _filterStatut == null && _filterDate == null
                                      ? 'Aucune alerte enregistrée'
                                      : 'Aucune alerte trouvée',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ListView.builder(
                              itemCount: filteredAlerts.length,
                              itemBuilder: (context, index) {
                                return _buildAlertCard(filteredAlerts[index], provider);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Tous')),
        ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: _filterDate != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _filterDate = null),
              )
            : const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: _filterDate != null ? DateFormat('dd/MM/yyyy').format(_filterDate!) : '',
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _filterDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _filterDate = date);
        }
      },
    );
  }

  Widget _buildAlertCard(Alert alert, AlertProvider provider) {
    Color prioriteColor;
    IconData prioriteIcon;
    switch (alert.priorite) {
      case 'CRITIQUE':
        prioriteColor = const Color(0xFFEF4444);
        prioriteIcon = Icons.error;
        break;
      case 'ELEVEE':
        prioriteColor = const Color(0xFFF97316);
        prioriteIcon = Icons.warning;
        break;
      case 'MOYENNE':
        prioriteColor = const Color(0xFFF59E0B);
        prioriteIcon = Icons.info;
        break;
      case 'FAIBLE':
        prioriteColor = const Color(0xFF10B981);
        prioriteIcon = Icons.check_circle;
        break;
      default:
        prioriteColor = Colors.grey;
        prioriteIcon = Icons.notifications;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: alert.resolu ? Colors.grey[300]! : prioriteColor.withOpacity(0.3)),
      ),
      child: Opacity(
        opacity: alert.resolu ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: prioriteColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(prioriteIcon, color: prioriteColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.titre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: prioriteColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alert.priorite,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: prioriteColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alert.categorie,
                                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (alert.resolu)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'RÉSOLU',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                alert.message,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    alert.createdAt != null 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(alert.createdAt!) 
                        : 'Date inconnue',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (alert.assigneA != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      alert.assigneA!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!alert.resolu)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await provider.markAsResolved(alert.id!);
                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alerte marquée comme résolue'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Résoudre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final success = await provider.deleteAlert(alert.id!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Alerte supprimée' : 'Erreur lors de la suppression'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
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
      ),
    );
  }
}
