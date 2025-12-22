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
  bool _showFilters = false;

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

      return matchesSearch && matchesPriorite && matchesStatut;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        final stats = provider.alertStats;
        final filteredAlerts = _getFilteredAlerts(provider.alerts);
        final isMobile = ResponsiveLayout.isMobile(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              _buildHeader(isMobile),
              const SizedBox(height: 24),

              // Nouvelle alerte button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateAlertDialog(context, provider),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouvelle alerte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats cards grid 2x2
              if (stats != null) _buildStatsGrid(stats, isMobile),
              const SizedBox(height: 24),

              // Filters section
              _buildFiltersSection(),
              const SizedBox(height: 24),

              // Alerts table/list
              if (provider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                ))
              else if (filteredAlerts.isEmpty)
                _buildEmptyState()
              else
                _buildAlertsTable(filteredAlerts, provider, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertes & Anomalies',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 4),
        Text(
          'Gestion des alertes et anomalies financières détectées',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats, bool isMobile) {
    final total = stats['total'] ?? 0;
    final critiques = stats['critiques'] ?? 0;
    final resolues = stats['resolues'] ?? 0;
    final taux = stats['tauxResolution'] ?? 0;

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.4 : 1.8,
      children: [
        _buildStatCard('Total alertes', total.toString(), null, const Color(0xFF1F2937)),
        _buildStatCard('Critiques', critiques.toString(), null, const Color(0xFFEF4444)),
        _buildStatCard('Résolues', resolues.toString(), null, const Color(0xFF10B981)),
        _buildStatCard('Taux résolution', '$taux%', null, const Color(0xFF0284C7)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData? icon, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: valueColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(Icons.filter_alt_outlined, color: const Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 4),
                  Text(_showFilters ? 'Masquer' : 'Afficher', style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterPriorite,
                          decoration: InputDecoration(
                            labelText: 'Priorité',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Toutes')),
                            DropdownMenuItem(value: 'CRITIQUE', child: Text('Critique')),
                            DropdownMenuItem(value: 'ELEVEE', child: Text('Élevée')),
                            DropdownMenuItem(value: 'MOYENNE', child: Text('Moyenne')),
                            DropdownMenuItem(value: 'FAIBLE', child: Text('Faible')),
                          ],
                          onChanged: (v) => setState(() => _filterPriorite = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterStatut,
                          decoration: InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tous')),
                            DropdownMenuItem(value: 'RESOLU', child: Text('Résolu')),
                            DropdownMenuItem(value: 'NON_RESOLU', child: Text('Non résolu')),
                          ],
                          onChanged: (v) => setState(() => _filterStatut = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Aucune alerte trouvée', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAlertsTable(List<Alert> alerts, AlertProvider provider, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Table header
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
                  Expanded(flex: 2, child: Text('Service', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
                  Expanded(flex: 4, child: Text('Message', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
                  Expanded(flex: 1, child: Text('Montant', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
                  Expanded(flex: 1, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
                ],
              ),
            ),
          // Table rows
          ...alerts.map((alert) => _buildAlertRow(alert, provider, isMobile)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertRow(Alert alert, AlertProvider provider, bool isMobile) {
    final date = alert.createdAt != null 
        ? DateFormat('dd/MM/yyyy\nHH:mm').format(alert.createdAt!)
        : '-';
    
    Color prioriteColor;
    switch (alert.priorite) {
      case 'CRITIQUE':
        prioriteColor = const Color(0xFFEF4444);
        break;
      case 'ELEVEE':
        prioriteColor = const Color(0xFFF97316);
        break;
      case 'MOYENNE':
        prioriteColor = const Color(0xFFF59E0B);
        break;
      default:
        prioriteColor = const Color(0xFF10B981);
    }

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioriteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(alert.priorite, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: prioriteColor)),
                ),
                const Spacer(),
                Text(alert.createdAt != null ? DateFormat('dd/MM/yyyy').format(alert.createdAt!) : '-', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(alert.message, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(alert.categorie, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const Spacer(),
                if (!alert.resolu)
                  TextButton(
                    onPressed: () => provider.markAsResolved(alert.id!),
                    child: const Text('Résoudre', style: TextStyle(color: Color(0xFF10B981))),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
          Expanded(flex: 2, child: Text(alert.categorie, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: prioriteColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(alert.titre, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alert.message, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: alert.resolu 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Résolu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                  )
                : Text(alert.priorite[0], style: TextStyle(fontWeight: FontWeight.bold, color: prioriteColor)),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (!alert.resolu)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                    onPressed: () => provider.markAsResolved(alert.id!),
                    tooltip: 'Marquer comme résolu',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => _confirmDelete(alert, provider),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Alert alert, AlertProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'alerte'),
        content: Text('Voulez-vous vraiment supprimer "${alert.titre}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteAlert(alert.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateAlertDialog(BuildContext context, AlertProvider provider) {
    final formKey = GlobalKey<FormState>();
    final titreController = TextEditingController();
    final messageController = TextEditingController();
    final categorieController = TextEditingController();
    final assigneController = TextEditingController();
    final commentaireController = TextEditingController();
    String selectedType = 'INFO';
    String selectedPriorite = 'MOYENNE';

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
                        const Expanded(child: Text('Nouvelle alerte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Titre', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: titreController,
                            decoration: InputDecoration(
                              hintText: 'Titre de l\'alerte',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Message', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: messageController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Message détaillé',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: categorieController,
                            decoration: InputDecoration(
                              hintText: 'Ex: Budget, Ressources, Maintenance',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedType,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      items: ['INFO', 'WARNING', 'ERROR', 'SUCCESS'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                      onChanged: (v) { if (v != null) setState(() => selectedType = v); },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Priorité', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedPriorite,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      items: ['FAIBLE', 'MOYENNE', 'ELEVEE', 'CRITIQUE'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                      onChanged: (v) { if (v != null) setState(() => selectedPriorite = v); },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Assigné à', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: assigneController,
                            decoration: InputDecoration(
                              hintText: 'Nom du responsable',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          const Text('Commentaire', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: commentaireController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Commentaire ou notes...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler', style: TextStyle(color: Color(0xFF0284C7))),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final alert = Alert(
                                titre: titreController.text.trim(),
                                message: messageController.text.trim(),
                                type: selectedType,
                                priorite: selectedPriorite,
                                categorie: categorieController.text.trim(),
                                assigneA: assigneController.text.trim().isEmpty ? null : assigneController.text.trim(),
                                commentaire: commentaireController.text.trim().isEmpty ? null : commentaireController.text.trim(),
                              );
                              
                              Navigator.pop(context);
                              final success = await provider.createAlert(alert);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(success ? 'Alerte créée avec succès' : 'Erreur lors de la création'),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                ));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          child: const Text('Créer'),
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
}

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({super.key, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
