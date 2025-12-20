import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/sejour_provider.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/providers/service_provider.dart';
import 'package:flutter_app/models/sejour.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';

class SejoursScreen extends StatefulWidget {
  const SejoursScreen({Key? key}) : super(key: key);

  @override
  State<SejoursScreen> createState() => _SejoursScreenState();
}

class _SejoursScreenState extends State<SejoursScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'TOUS';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SejourProvider>().loadSejours();
      context.read<PatientProvider>().loadPatients();
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Sejour> _filterSejours(List<Sejour> sejours) {
    var filtered = sejours;
    
    if (_filterStatus != 'TOUS') {
      filtered = filtered.where((s) => s.statut == _filterStatus).toList();
    }
    
    if (_searchQuery.isEmpty) return filtered;
    
    return filtered.where((sejour) {
      final searchLower = _searchQuery.toLowerCase();
      return (sejour.patientNom?.toLowerCase().contains(searchLower) ?? false) ||
          (sejour.patientPrenom?.toLowerCase().contains(searchLower) ?? false) ||
          (sejour.serviceNom?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<SejourProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Erreur: ${provider.error}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final filteredSejours = _filterSejours(provider.sejours);

                if (filteredSejours.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bed_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun séjour trouvé',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredSejours.length,
                  itemBuilder: (context, index) {
                    return _buildSejourCard(filteredSejours[index]);
                  },
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Séjours',
            style: TextStyle(
              fontSize: ResponsiveLayout.isMobile(context) ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestion des hospitalisations',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SearchBarWidget(
            hintText: 'Rechercher par patient ou service...',
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'TOUS', child: Text('Tous les statuts')),
                        DropdownMenuItem(value: 'EN_COURS', child: Text('En cours')),
                        DropdownMenuItem(value: 'TERMINE', child: Text('Terminé')),
                        DropdownMenuItem(value: 'ANNULE', child: Text('Annulé')),
                      ],
                      onChanged: (v) => setState(() => _filterStatus = v!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showSejourDialog(null),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nouveau Séjour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<SejourProvider>(
            builder: (context, provider, _) {
              final count = _filterSejours(provider.sejours).length;
              return Text(
                '$count séjour(s) trouvé(s)',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSejourCard(Sejour sejour) {
    Color statusColor;
    String statusLabel;
    switch (sejour.statut) {
      case 'EN_COURS':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'EN COURS';
        break;
      case 'TERMINE':
        statusColor = const Color(0xFF8B5CF6);
        statusLabel = 'TERMINÉ';
        break;
      case 'ANNULE':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'ANNULÉ';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = sejour.statut;
    }

    final duree = _calculateDuration(sejour.dateEntree, sejour.dateSortie);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bed, color: Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sejour.patientPrenom} ${sejour.patientNom}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      _buildInfoRow(Icons.local_hospital_outlined, sejour.serviceNom ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.calendar_today, 'Entrée: ${_formatDate(sejour.dateEntree)}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.event, 'Sortie: ${sejour.dateSortie != null ? _formatDate(sejour.dateSortie!) : 'En cours'}'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, 'Durée: $duree'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Motif:', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(
                        sejour.motif,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text('Diagnostic:', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(
                        sejour.diagnostic ?? 'Non renseigné',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (sejour.coutTotal != null) ...[
              const SizedBox(height: 12),
              Text(
                '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(sejour.coutTotal)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSejourDialog(sejour),
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Modifier', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(sejour),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  String _calculateDuration(String dateEntree, String? dateSortie) {
    try {
      final entree = DateTime.parse(dateEntree);
      final sortie = dateSortie != null ? DateTime.parse(dateSortie) : DateTime.now();
      final diff = sortie.difference(entree).inDays;
      return '$diff jour(s)';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showSejourDialog(Sejour? sejour) {
    // Implement dialog similar to patients
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sejour == null ? 'Nouveau Séjour' : 'Modifier Séjour'),
        content: const Text('Formulaire de création/modification à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Sejour sejour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le séjour'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce séjour ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<SejourProvider>().deleteSejour(sejour.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Séjour supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
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
